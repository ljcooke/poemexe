.PHONY: model test

model:
	bundle exec ruby bin/build-model
	bundle exec scripts/test-model

test:
	bundle exec ruby lib/poem_exe.rb
