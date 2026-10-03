#!/usr/bin/env python
import argparse
import sys
import re
from collections import namedtuple


Script = namedtuple("Script", ["address", "pattern", "replacement", "modifier"])


def script_fmt(script):

    if not script:
        return []

    parts = script.split("s", 1)
    if len(parts) != 2:
        raise argparse.ArgumentTypeError(f"Invalid script: {parts}")
    address, replace_args = parts
    parts = replace_args.split("/")
    if len(parts) != 4:
        raise argparse.ArgumentTypeError(f"Invalid replacement arguments: {parts}")
    _, pattern, replacement, modifier = parts
    if modifier and modifier != "g":
        raise argparse.ArgumentTypeError(f"Invalid modifier: {modifier}")
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
        raise argparse.ArgumentTypeError(exc)

    return Script(address, re.compile(pattern), replacement, modifier)


def process(file, scripts):

    for i, line in enumerate(file):
        for script in scripts:
            count = 0 if script.modifier else 1

            if not script.address:
                do_search = True
            elif isinstance(script.address, tuple):
                start, end = script.address
                do_search = start <= i + 1 <= end
            else:
                do_search = i + 1 == script.address

            if do_search:
                line = script.pattern.sub(script.replacement, line, count)
        yield line


def main(args):
    scripts = []
    for script in [args.script] + (args.scripts or []):
        if not script:
            continue
        scripts.append(script)
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
