#!/usr/bin/env bash
set -euo pipefail

SORT="${SORT:-./sort}"

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

# 1. Sort lines from stdin (default lexicographic)
test_stdin_sort() {
    printf "c\na\nb\n" | "$SORT" > "$actual"
    printf "c\na\nb\n" | sort > "$expected"
    assert_equal "stdin sort" "$actual" "$expected"
}

# 2. Sort a file
test_file_sort() {
    local input
    input=$(mktemp)
    printf "z\ny\nx\n" > "$input"
    "$SORT" "$input" > "$actual"
    sort "$input" > "$expected"
    assert_equal "file sort" "$actual" "$expected"
    rm -f "$input"
}

# 3. Numeric sort
test_numeric_sort() {
    local input
    input=$(mktemp)
    printf "10\n2\n1\n" > "$input"
    "$SORT" -n "$input" > "$actual"
    sort -n "$input" > "$expected"
    assert_equal "numeric sort" "$actual" "$expected"
    rm -f "$input"
}

# 4. Reverse order
test_reverse_sort() {
    local input
    input=$(mktemp)
    printf "a\nc\nb\n" > "$input"
    "$SORT" -r "$input" > "$actual"
    sort -r "$input" > "$expected"
    assert_equal "reverse sort" "$actual" "$expected"
    rm -f "$input"
}

# Run tests
test_stdin_sort
test_file_sort
test_numeric_sort
test_reverse_sort

echo "----------------------------------------"
echo "Results: $pass_count passed, $fail_count failed"
if ((fail_count > 0)); then
    exit 1
fi
