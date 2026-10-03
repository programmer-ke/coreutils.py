#!/usr/bin/env bash
set -euo pipefail

CUT="${CUT:-./cut}"

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

# Test cases covering the 5 uses we kept:
# 1. stdin, default delimiter
# 2. file, custom delimiter
# 3. character positions
# 4. custom delimiter (comma)
# 5. complement

test_stdin_tab() {
    printf "a\tb\tc\n" | "$CUT" -f2 > "$actual"
    printf "a\tb\tc\n" | cut -f2 > "$expected"
    assert_equal "stdin, tab delimiter, field 2" "$actual" "$expected"
}

test_file_delim() {
    "$CUT" -d':' -f1,3 /etc/passwd > "$actual"
    cut -d':' -f1,3 /etc/passwd > "$expected"
    assert_equal "file, colon delimiter, fields 1,3" "$actual" "$expected"
}

test_char_pos() {
    echo "abcdef" | "$CUT" -c2-4 > "$actual"
    echo "abcdef" | cut -c2-4 > "$expected"
    assert_equal "character positions 2-4" "$actual" "$expected"
}

test_custom_delim() {
    echo "a,b,c" | "$CUT" -d',' -f2 > "$actual"
    echo "a,b,c" | cut -d',' -f2 > "$expected"
    assert_equal "comma delimiter, field 2" "$actual" "$expected"
}

test_complement() {
    echo "a:b:c:d" | "$CUT" -d':' --complement -f2 > "$actual"
    echo "a:b:c:d" | cut -d':' --complement -f2 > "$expected"
    assert_equal "complement field 2" "$actual" "$expected"
}

test_multiple_files() {
    local file1 file2
    file1=$(mktemp)
    file2=$(mktemp)
    # create simple tab-delimited data
    printf '1\ta\tx\n2\tb\ty\n' > "$file1"
    printf '3\tc\tz\n4\td\tw\n' > "$file2"
    "$CUT" -f2 "$file1" "$file2" > "$actual"
    cut  -f2 "$file1" "$file2" > "$expected"
    assert_equal "multiple files, field 2" "$actual" "$expected"
    rm -f "$file1" "$file2"
}

# Run tests
test_stdin_tab
test_file_delim
test_char_pos
test_custom_delim
test_complement
test_multiple_files

echo "----------------------------------------"
echo "Results: $pass_count passed, $fail_count failed"
if ((fail_count > 0)); then
    exit 1
fi
