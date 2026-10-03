#!/usr/bin/env python
import argparse
import sys
import re

def script_fmt(script):
    parts = script.split("s", 1)
    if len(parts) != 2:
        raise argparse.ArgumentError(f"Invalid script: {parts}")
    address, replace_args = parts
    parts = replace_args.split("/")
    if len(parts) != 4:
        raise argparse.ArgumentError(f"Invalid replacement arguments: {parts}")
    _, pattern, replacement, modifier = parts
    return [address, pattern, replacement, modifier]


def process(file, expr, replacement):
    for line in file:
        yield expr.sub(replacement, line, count=1)
        
        
def main(args):
    address, pattern, replacement, modifier = args.script
    expr = re.compile(pattern)
    outputs = process(sys.stdin, expr, replacement)
    for l in outputs:
        print(l, end="")
        

if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog="sed", description="stream editor")
    parser.add_argument('script', type=script_fmt, help="script to execute on lines")
    args = parser.parse_args()
    main(args)
