#!/usr/bin/env bash
set -euo pipefail

SED="${SED:-./sed}"

pass=0
fail=0

assert_equal() {
    local name="$1" actual="$2" expected="$3"
    if diff -q "$actual" "$expected" >/dev/null 2>&1; then
        echo "PASS: $name"
        ((pass++)) || true
    else
        echo "FAIL: $name"
        echo "  Expected:"
        cat "$expected"
        echo "  Got:"
        cat "$actual"
        ((fail++)) || true
    fi
}

actual=$(mktemp)
expected=$(mktemp)
trap 'rm -f "$actual" "$expected"' EXIT

# 1. Simple substitution
echo "hello world. it's a wonderful world" | "$SED" 's/world/there/' > "$actual"
echo "hello world. it's a wonderful world" | sed 's/world/there/' > "$expected"
assert_equal "simple substitution" "$actual" "$expected"

# 2. Global substitution
echo "one one one" | "$SED" 's/one/two/g' > "$actual"
echo "one one one" | sed 's/one/two/g' > "$expected"
assert_equal "global substitution" "$actual" "$expected"

# 3. Line-number address (single line)
printf "line1\nline2\nline3\n" | "$SED" '2s/line/LINE/' > "$actual"
printf "line1\nline2\nline3\n" | sed '2s/line/LINE/' > "$expected"
assert_equal "single line address" "$actual" "$expected"

# 4. Line-number range address
printf "a\nb\nc\nd\n" | "$SED" '2,3s/[a-z]/X/g' > "$actual"
printf "a\nb\nc\nd\n" | sed '2,3s/[a-z]/X/g' > "$expected"
assert_equal "line range address" "$actual" "$expected"

# 5. Multiple -e expressions
echo "apple banana" | "$SED" -e 's/apple/orange/' -e 's/banana/grape/' > "$actual"
echo "apple banana" | sed -e 's/apple/orange/' -e 's/banana/grape/' > "$expected"
assert_equal "multiple -e expressions" "$actual" "$expected"

# 6. No match (should output unchanged)
echo "nothing here" | "$SED" 's/foo/bar/' > "$actual"
echo "nothing here" | sed 's/foo/bar/' > "$expected"
assert_equal "no match" "$actual" "$expected"

echo "----------------------------------------"
echo "Results: $pass passed, $fail failed"
if ((fail > 0)); then
    exit 1
fi
