#!/usr/bin/env python3
import codecs
import json
import os
import sys
from glob import glob


OUTPUT_FILENAME = '../model/words.json'


def read_wordlist(fn):
    with codecs.open(fn, 'r', encoding='utf-8') as wordlist:
        for line in wordlist:
            line = line.split('#', 1)[0].strip()
            if not line:
                continue
            tokens = line.split('/')
            if tokens:
                yield tuple(tokens)


def compile_words(export=False):
    vocab = {}

    for fn in glob('wordlists/*.txt'):
        name = os.path.splitext(os.path.basename(fn))[0]
        vocab[name] = tuple(read_wordlist(fn))

    if export:
        with codecs.open(OUTPUT_FILENAME, 'w', encoding='utf-8') as vocabfile:
            json.dump(vocab, vocabfile, indent=2, sort_keys=True, ensure_ascii=False)

        print('Wrote wordlists:')
        for key, words in sorted(vocab.items()):
            print('%7d %s' % (len(words), key))

    return vocab


def main():
    compile_words(export=True)

if __name__ == '__main__':
    sys.exit(main())
