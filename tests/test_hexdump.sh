#!/usr/bin/env bash
set -euo pipefail

HEXDUMP="${HEXDUMP:-./hexdump}"
SYSTEM_HEXDUMP="hexdump"   # assumes system hexdump is available

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
input=$(mktemp)
trap 'rm -f "$actual" "$expected" "$input"' EXIT

# 1. Stdin, no flags
test_stdin_no_flags() {
    printf "AB" > "$input"
    "$SYSTEM_HEXDUMP" < "$input" > "$expected"
    "$HEXDUMP" < "$input" > "$actual"
    assert_equal "stdin no flags" "$actual" "$expected"
}

# 2. Stdin with -C flag
test_stdin_C() {
    printf "Hello" > "$input"
    "$SYSTEM_HEXDUMP" -C < "$input" > "$expected"
    "$HEXDUMP" -C < "$input" > "$actual"
    assert_equal "stdin -C" "$actual" "$expected"
}

# 3. Empty input (no flags)
test_empty_no_flags() {
    printf "" > "$input"
    "$SYSTEM_HEXDUMP" < "$input" > "$expected"
    "$HEXDUMP" < "$input" > "$actual"
    assert_equal "empty stdin no flags" "$actual" "$expected"
}

# 4. Empty input with -C
test_empty_C() {
    printf "" > "$input"
    "$SYSTEM_HEXDUMP" -C < "$input" > "$expected"
    "$HEXDUMP" -C < "$input" > "$actual"
    assert_equal "empty stdin -C" "$actual" "$expected"
}

# 5. Binary data with -C
test_binary_C() {
    printf "\x00\x01\xff" > "$input"
    "$SYSTEM_HEXDUMP" -C < "$input" > "$expected"
    "$HEXDUMP" -C < "$input" > "$actual"
    assert_equal "binary -C" "$actual" "$expected"
}

# 6. Long input (multiple lines) with -C
test_long_C() {
    printf "AAAAAAAAAAAAAAAAAAAA" > "$input"
    "$SYSTEM_HEXDUMP" -C < "$input" > "$expected"
    "$HEXDUMP" -C < "$input" > "$actual"
    assert_equal "long input -C" "$actual" "$expected"
}

# 7. File redirection with -C (if data/file1.txt exists)
test_file_redirect_C() {
    if [[ -f data/file1.txt ]]; then
        "$SYSTEM_HEXDUMP" -C < data/file1.txt > "$expected"
        "$HEXDUMP" -C < data/file1.txt > "$actual"
        assert_equal "file redirect -C" "$actual" "$expected"
    else
        echo "SKIP: data/file1.txt not found"
    fi
}

# Run tests
test_stdin_no_flags
test_stdin_C
test_empty_no_flags
test_empty_C
test_binary_C
test_long_C
test_file_redirect_C

echo "----------------------------------------"
echo "Results: $pass_count passed, $fail_count failed"
if ((fail_count > 0)); then
    exit 1
fi
