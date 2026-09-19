#!/usr/bin/env bash
# tests/test_cat.sh – Tests for cat coreutils behaviours

set -euo pipefail

# Path to cat executable under test; override with env var if needed
CAT="${CAT:-./cat}"

# --- helpers ---
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

cleanup() {
    rm -f "$tmp_actual" "$tmp_expected" "$tmp_input" "$tmp_append"
}
trap cleanup EXIT

tmp_actual=$(mktemp)
tmp_expected=$(mktemp)
tmp_input=$(mktemp)
tmp_append=$(mktemp)

# --- test 1: no arguments, echo input ---
test_no_args() {
    echo "hello world" | "$CAT" > "$tmp_actual"
    echo "hello world" > "$tmp_expected"
    assert_equal "1. No arguments echoes input" "$tmp_actual" "$tmp_expected"
}

# --- test 2: display a single file ---
test_single_file() {
    "$CAT" data/file1.txt > "$tmp_actual"
    cp data/file1.txt "$tmp_expected"
    assert_equal "2. Display single file" "$tmp_actual" "$tmp_expected"
}

# --- test 3: concatenate multiple files ---
test_concat_files() {
    "$CAT" data/file1.txt data/file2.txt > "$tmp_actual"
    cat data/file1.txt data/file2.txt > "$tmp_expected"
    assert_equal "3. Concatenate two files" "$tmp_actual" "$tmp_expected"
}

# --- test 4: create a new file (redirect) ---
test_create_file() {
    echo "new content" | "$CAT" > "$tmp_input"
    echo "new content" > "$tmp_expected"
    assert_equal "4. Create new file via redirection" "$tmp_input" "$tmp_expected"
}

# --- test 5: append to existing file ---
test_append_file() {
    echo "line 1" > "$tmp_append"
    echo "line 2" | "$CAT" >> "$tmp_append"
    printf "line 1\nline 2\n" > "$tmp_expected"
    assert_equal "5. Append to file" "$tmp_append" "$tmp_expected"
}

# --- test 6: show line numbers (-n) ---
test_line_numbers() {
    "$CAT" -n data/multiline.txt > "$tmp_actual"
    # Build expected output with line numbers
    awk '{printf "%6d\t%s\n", NR, $0}' data/multiline.txt > "$tmp_expected"
    assert_equal "6. Line numbers (-n)" "$tmp_actual" "$tmp_expected"
}

# --- test 7: here-document ---
test_heredoc() {
    "$CAT" <<EOF > "$tmp_actual"
line one
line two
EOF
    printf "line one\nline two\n" > "$tmp_expected"
    assert_equal "7. Here-document" "$tmp_actual" "$tmp_expected"
}

# --- test 8: stdin in argument list ---
test_stdin_argument_list() {
    cat data/file2.txt | "$CAT" data/file1.txt - data/multiline.txt > "$tmp_actual"
    cat data/file1.txt data/file2.txt data/multiline.txt > "$tmp_expected"
    assert_equal "8. stdin in argument list" "$tmp_actual" "$tmp_expected"
}

# --- run all tests ---
main() {
    test_no_args
    test_single_file
    test_concat_files
    test_create_file
    test_append_file
    test_line_numbers
    test_heredoc
    test_stdin_argument_list

    echo "----------------------------------------"
    echo "Results: $pass_count passed, $fail_count failed"
    if [ "$fail_count" -gt 0 ]; then
        exit 1
    fi
}

main "$@"
