#!/usr/bin/env python3
import json
import os
import sys

from compile_verses import convert_dir as compile_verses
from compile_wordlists import compile_words


OUTPUT_FILENAME = '../model.json'


def compile_excludes(data_dir):
    with open(os.path.join(data_dir, 'excludes.txt'), encoding='utf-8') as fp:
        for line in fp:
            line = line.split('#', 1)[0].strip()
            if line:
                yield line


def compile_all(data_dir, export=True):
    verses = compile_verses(os.path.join(data_dir, 'sources'))
    print('Verses: {}'.format(len(verses)))

    words = compile_words(os.path.join(data_dir, 'wordlists'))
    print('Word lists: {}'.format(len(words)))
    for key, vals in sorted(words.items()):
        print(' %6d %s' % (len(vals), key))

    excludes = tuple(compile_excludes(data_dir))
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
    data_dir = os.environ.get('POEMEXE_DATA', '.')
    compile_all(data_dir)

if __name__ == '__main__':
    sys.exit(main())
