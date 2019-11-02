.PHONY: corpus test clean

corpus:
	(cd corpus && make)
	bundle exec scripts/test-model

test:
	bundle exec ruby lib/poem_exe.rb

clean:
	rm -f model/*
	rmdir model
