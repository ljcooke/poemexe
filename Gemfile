# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'mastodon-api', require: 'mastodon',
                    git: 'https://github.com/tootsuite/mastodon-api.git',
                    ref: '189deb8219ae1ce7c34386d9ad1ca7e4a5fec62c'
gem 'twitter'

group :development, optional: true do
  gem 'rubocop'
end
