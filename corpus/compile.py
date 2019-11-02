#!/usr/bin/env python3
import argparse
import json
import sys

from compile_verses import convert_dirs as compile_verses
from compile_wordlists import compile_words


OUTPUT_FILENAME = '../model.json'


def compile_excludes(path='excludes.txt'):
    with open(path, encoding='utf-8') as fp:
        for line in fp:
            line = line.split('#', 1)[0].strip()
            if line:
                yield line


def compile_all(dirs, export=True):
    verses = compile_verses(dirs)
    print('Verses: {}'.format(len(verses)))

    words = compile_words()
    print('Word lists: {}'.format(len(words)))
    for key, vals in sorted(words.items()):
        print(' %6d %s' % (len(vals), key))

    excludes = tuple(compile_excludes())
    print('Exclude rules: {}'.format(len(excludes)))

    result = {
        'verses': verses,
        'words': words,
        'excludes': excludes,
    }

    if export:
        with open(OUTPUT_FILENAME, 'w', encoding='utf-8') as fp:
            json.dump(result, fp, indent=2, sort_keys=True, ensure_ascii=False)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('srcdir', nargs='*')
    args = parser.parse_args()

    if not args.srcdir:
        parser.print_help()
        return 1

    compile_all(args.srcdir)

if __name__ == '__main__':
    sys.exit(main())
