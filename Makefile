.PHONY: corpus

corpus:
	mkdir -p corpus
	python convert_haiku.py sources/
	python convert_wordlists.py
	ruby test_corpus.rb
