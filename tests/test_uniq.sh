#!/usr/bin/env bash
set -euo pipefail

UNIQ="${UNIQ:-./uniq}"

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

# 1. Remove adjacent duplicate lines (default)
test_uniq_default() {
    local input
    input=$(mktemp)
    printf "a\na\nb\nb\na\n" > "$input"
    "$UNIQ" "$input" > "$actual"
    uniq "$input" > "$expected"
    assert_equal "remove adjacent duplicates" "$actual" "$expected"
    rm -f "$input"
}

# 2. Count occurrences
test_uniq_count() {
    local input
    input=$(mktemp)
    printf "a\na\nb\nb\nb\nc\n" > "$input"
    "$UNIQ" -c "$input" > "$actual"
    uniq -c "$input" > "$expected"
    assert_equal "count occurrences" "$actual" "$expected"
    rm -f "$input"
}

# Run tests
test_uniq_default
test_uniq_count

echo "----------------------------------------"
echo "Results: $pass_count passed, $fail_count failed"
if ((fail_count > 0)); then
    exit 1
fi
