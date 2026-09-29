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

# --- Test 1.a: no arguments ---
test_no_args() {
    "$FIND"  > "$actual"
    find > "$expected"
    assert_sorted_equal "1.a No arguments lists everything" "$actual" "$expected"
}

# --- Test 1.b: no glob pattern ---
test_no_glob_pattern() {
    "$FIND" data > "$actual"
    find data > "$expected"
    assert_sorted_equal "1.b No glob pattern lists everything in destination" "$actual" "$expected"
}

# --- Test 2.a: find by name pattern current directory ---
test_name_glob() {
    "$FIND" . -name "*.txt" > "$actual"
    find . -name "*.txt" > "$expected"
    assert_sorted_equal "2.a Find by name pattern current directory" "$actual" "$expected"
}

# --- Test 2.b: find by name pattern different directory ---
test_name_glob_different_directory() {
    "$FIND" data -name "*.txt" > "$actual"
    find data -name "*.txt" > "$expected"
    assert_sorted_equal "2.b Find by name pattern different directory" "$actual" "$expected"
}

# --- Test 3.a: find directories only ---
test_type_dir() {
    "$FIND" . -type d > "$actual"
    find . -type d > "$expected"
    assert_sorted_equal "3.a Find directories only" "$actual" "$expected"
}

# --- Test 3.b: find regular files only ---
test_type_file() {
    "$FIND" . -type f > "$actual"
    find . -type f > "$expected"
    assert_sorted_equal "3.b Find regular files only" "$actual" "$expected"
}

# --- Test 4.a: find by modification time < 3 days ---
test_mtime_lt_3() {
    "$FIND" . -mtime -3 > "$actual"
    find . -mtime -3 > "$expected"
    assert_sorted_equal "4.a Find by modification time < 3 days" "$actual" "$expected"
}


# --- Test 4.b: find by modification time == 3 days ---
test_mtime_eq_3() {
    "$FIND" . -mtime 3 > "$actual"
    find . -mtime 3 > "$expected"
    assert_sorted_equal "4.b Find by modification time == 3 days" "$actual" "$expected"
}

# --- Test 4.c: find by modification time > 3 days ---
test_mtime_gt_3() {
    "$FIND" . -mtime +3 > "$actual"
    find . -mtime +3 > "$expected"
    assert_sorted_equal "4.c Find by modification time > 3 days" "$actual" "$expected"
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
test_no_glob_pattern
test_name_glob
test_name_glob_different_directory
test_type_dir
test_type_file
test_mtime_lt_3
test_mtime_eq_3
test_mtime_gt_3
#test_exec
#test_print0_and_xargs

echo "----------------------------------------"
echo "Results: $pass_count passed, $fail_count failed"
