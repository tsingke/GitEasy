#!/usr/bin/env python3
"""Copy the offline seed into a NEW destination; never initialize or push Git."""
import argparse
from pathlib import Path
import shutil

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('destination', type=Path)
    args = parser.parse_args()
    source = Path(__file__).resolve().parents[1] / 'seed'
    try:
        shutil.copytree(source, args.destination)
    except FileExistsError:
        parser.exit(2, 'Destination already exists; choose a new directory.\n')
    print(f'Created seed: {args.destination.resolve()}')
    print('Next: cd into it, git init -b main, configure identity, inspect and commit.')

if __name__ == '__main__':
    main()
