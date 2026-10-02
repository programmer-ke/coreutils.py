#!/usr/bin/env bash
set -euo pipefail

GREP="${GREP:-./grep}"

pass_count=0
fail_count=0

assert_equal() {
    local test_name="$1"
    local actual="$2"
    local expected="$3"
    if diff -q "$actual" "$expected" >/dev/null 2>&1; then
        echo "PASS: $test_name"
        ((pass_count++)) || true
    else
        echo "FAIL: $test_name"
        echo "  Expected:"
        cat "$expected"
        echo "  Got:"
        cat "$actual"
        ((fail_count++)) || true
    fi
}

actual=$(mktemp)
expected=$(mktemp)
trap 'rm -f "$actual" "$expected"' EXIT

# 1. Simplest case: pipe text to grep
test_stdin() {
    echo "hello world" | "$GREP" "hello" > "$actual"
    echo "hello world" | grep -E "hello" > "$expected"
    assert_equal "1. Pipe text to grep" "$actual" "$expected"
}

# 2. Search file with a regex pattern (alternation)
test_file_regex() {
    "$GREP" "file|two" data/file1.txt data/file2.txt > "$actual"
    grep -E "file|two" data/file1.txt data/file2.txt > "$expected"
    assert_equal "2. Search file with regex" "$actual" "$expected"
}

# 3. Case-insensitive search
test_case_insensitive() {
    "$GREP" -i "hello" data/file1.txt > "$actual"
    grep -Ei "hello" data/file1.txt > "$expected"
    assert_equal "3. Case-insensitive search" "$actual" "$expected"
}

# 4. Recursive search
test_recursive() {
    "$GREP" -r "two" data > "$actual"
    grep -Er "two" data > "$expected"
    sort "$actual" -o "$actual"
    sort "$expected" -o "$expected"
    assert_equal "4. Recursive search" "$actual" "$expected"
}

# 5. Show line numbers
test_line_numbers() {
    "$GREP" -n "two" data/file1.txt data/file2.txt > "$actual"
    grep -En "two" data/file1.txt data/file2.txt > "$expected"
    assert_equal "5. Show line numbers" "$actual" "$expected"
}

# 6. Invert match
test_invert() {
    "$GREP" -v "two" data/file1.txt > "$actual"
    grep -Ev "two" data/file1.txt > "$expected"
    assert_equal "6. Invert match" "$actual" "$expected"
}

# 7. Count matching lines
test_count() {
    "$GREP" -c "two" data/file1.txt > "$actual"
    grep -Ec "two" data/file1.txt > "$expected"
    assert_equal "7. Count matching lines" "$actual" "$expected"
}

# Run all tests
test_stdin
test_file_regex
test_case_insensitive
test_recursive
test_line_numbers
test_invert
test_count

echo "----------------------------------------"
echo "Results: $pass_count passed, $fail_count failed"
if ((fail_count > 0)); then
    exit 1
fi
