#!/usr/bin/env bash
set -euo pipefail

FIND="${FIND:-./find}"

pass_count=0
fail_count=0

assert_sorted_equal() {
    local test_name="$1"
    local actual="$2"
    local expected="$3"
    if diff -q <(sort "$actual") <(sort "$expected") >/dev/null 2>&1; then
        echo "PASS: $test_name"
        ((pass_count++)) || true
    else
        echo "FAIL: $test_name"
        echo "  Expected (sorted):"
        sort "$expected"
        echo "  Got (sorted):"
        sort "$actual"
        ((fail_count++)) || true
    fi
}

# Helper for -print0: convert nulls to newlines, then sort and compare
assert_null_sorted_equal() {
    local test_name="$1"
    local actual="$2"
    local expected="$3"
    if diff -q <(tr '\0' '\n' < "$actual" | sort) <(tr '\0' '\n' < "$expected" | sort) >/dev/null 2>&1; then
        echo "PASS: $test_name"
        ((pass_count++)) || true
    else
        echo "FAIL: $test_name"
        echo "  Expected (null‑separated, sorted):"
        tr '\0' '\n' < "$expected" | sort
        echo "  Got (null‑separated, sorted):"
        tr '\0' '\n' < "$actual" | sort
        ((fail_count++)) || true
    fi
}

# Temporary files for output (not for the directory)
actual=$(mktemp)
expected=$(mktemp)
trap 'rm -f "$actual" "$expected"' EXIT

# --- Test 1: no arguments ---
test_no_args() {
    "$FIND"  > "$actual"
    find > "$expected"
    assert_sorted_equal "1. No arguments lists everything" "$actual" "$expected"
}

# --- Test 2: find by name pattern ---
test_name_glob() {
    "$FIND" . -name "*.txt" > "$actual"
    find . -name "*.txt" > "$expected"
    assert_sorted_equal "2. Find by name pattern" "$actual" "$expected"
}

# --- Test 3: find directories only ---
test_type_dir() {
    "$FIND" . -type d > "$actual"
    find . -type d > "$expected"
    assert_sorted_equal "3. Find directories only" "$actual" "$expected"
}

# --- Test 4: find by modification time ---
test_mtime() {
    "$FIND" . -mtime -365 > "$actual"
    find . -mtime -365 > "$expected"
    assert_sorted_equal "4. Find by modification time" "$actual" "$expected"
}

# --- Test 5: exec a command (non‑destructive) ---
test_exec() {
    "$FIND" . -name "*.txt" -exec echo {} \; > "$actual"
    find . -name "*.txt" -exec echo {} \; > "$expected"
    assert_sorted_equal "5. Exec command" "$actual" "$expected"
}

# --- Test 6: -print0 and xargs pipeline (non‑destructive) ---
test_print0_and_xargs() {
    # First, test -print0 alone
    "$FIND" . -name "*.txt" -print0 > "$actual"
    find . -name "*.txt" -print0 > "$expected"
    assert_null_sorted_equal "6a. Print0 output" "$actual" "$expected"

    # Then test the full pipeline with xargs -0 echo
    "$FIND" . -name "*.txt" -print0 | xargs -0 echo > "$actual"
    find . -name "*.txt" -print0 | xargs -0 echo > "$expected"
    if diff -q <(tr ' ' '\n' < "$actual" | sort) <(tr ' ' '\n' < "$expected" | sort) >/dev/null 2>&1; then
        echo "PASS: 6b. Print0 with xargs"
        ((pass_count++)) || true
    else
        echo "FAIL: 6b. Print0 with xargs"
        echo "  Expected (words sorted):"
        tr ' ' '\n' < "$expected" | sort
        echo "  Got (words sorted):"
        tr ' ' '\n' < "$actual" | sort
        ((fail_count++)) || true
    fi
}

# Run all tests
test_no_args
#test_name_glob
#test_type_dir
#test_mtime
#test_exec
#test_print0_and_xargs

echo "----------------------------------------"
echo "Results: $pass_count passed, $fail_count failed"
