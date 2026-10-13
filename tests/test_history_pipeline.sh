#!/usr/bin/env bash
set -euo pipefail

# Ensure history is enabled (some non-interactive shells disable it)
set -o history

# Capture history once to ensure both pipelines see identical input
hist=$(history)

# Run with system utilities
system_output=$(echo "$hist" | sed -e 's/^[0-9 ]*//' | cut -d' ' -f1 | sort | uniq)

# Run with custom implementations (adjust paths if needed)
custom_output=$(echo "$hist" | ./sed -e 's/^[0-9 ]*//' | ./cut -d' ' -f1 | ./sort | ./uniq)

# Compare
if diff <(echo "$system_output") <(echo "$custom_output") >/dev/null 2>&1; then
    echo "PASS: custom pipeline matches system pipeline"
else
    echo "FAIL: outputs differ"
    echo "System output:"
    echo "$system_output"
    echo "Custom output:"
    echo "$custom_output"
    exit 1
fi
