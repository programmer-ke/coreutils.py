#!/usr/bin/env python
import argparse
import sys
import re


def script_fmt(script):

    if not script:
        return []

    parts = script.split("s", 1)
    if len(parts) != 2:
        raise argparse.ArgumentError(f"Invalid script: {parts}")
    address, replace_args = parts
    parts = replace_args.split("/")
    if len(parts) != 4:
        raise argparse.ArgumentError(f"Invalid replacement arguments: {parts}")
    _, pattern, replacement, modifier = parts
    if modifier and modifier != "g":
        raise argparse.ArgumentError(f"Invalid modifier: {modifier}")
    try:
        if "," in address:
            start, end = address.split(",", 1)
            start, end = int(start), int(end)
            if start < 1 or start > end:
                raise ValueError(f"invalid address range: {(start, end)}")
            address = (start, end)
        else:
            address = int(address) if address else None
            if address == 0:
                raise ValueError(f"invalid address: {address}")

    except (TypeError, ValueError) as exc:
        raise argparse.ArgumentError(exc)

    return [address, pattern, replacement, modifier]


def process(file, scripts):

    for i, line in enumerate(file):
        for s in scripts:
            address, pattern, replacement, modifier = s
            count = 0 if modifier else 1

            if not address:
                do_search = True
            elif isinstance(address, tuple):
                start, end = address
                do_search = start <= i + 1 <= end
            else:
                do_search = i + 1 == address

            if do_search:
                line = pattern.sub(replacement, line, count)
        yield line


def main(args):
    scripts = []
    pattern_index = 1
    for s in [args.script] + (args.scripts or []):
        if not s:
            continue
        s[pattern_index] = re.compile(s[pattern_index])
        scripts.append(s)
    outputs = process(sys.stdin, scripts)
    for l in outputs:
        print(l, end="")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog="sed", description="stream editor")
    parser.add_argument(
        "script", nargs="?", type=script_fmt, help="script to execute on lines"
    )
    parser.add_argument(
        "-e",
        type=script_fmt,
        action="append",
        help="scripts to execute on lines",
        dest="scripts",
    )
    args = parser.parse_args()
    if not (args.script or args.scripts):
        parser.error("No scripts provided to execute")
    main(args)
