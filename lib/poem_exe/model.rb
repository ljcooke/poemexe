# frozen_string_literal: true

require 'json'
require_relative 'queneau'

module PoemExe
  DEFAULT_PATH = 'model.json'
  WORD_ENDINGS = %w[ed er e?s est ful ing liness ly ness].freeze

  class Model
    attr_reader :wordlists

    def initialize(path = DEFAULT_PATH)
      model = JSON.parse(File.read(path), symbolize_names: true)
      @queneau = PoemExe::Queneau.new(model[:verses])
      @wordlists = model[:words] || {}
      @exclude_patterns = model[:excludes].map do |rule|
        Regexp.new(rule, Regexp::IGNORECASE)
      end
      @tone_feature = wordlist?(:tone_dark) && wordlist?(:tone_bright)
    end

    def generate_lines
      queneau.sample.reject(&:empty?)
    end

    def excludes?(text)
      exclude_patterns.any? { |rule| rule.match(text) }
    end

    def tone_feature?
      @tone_feature
    end

    def dark_tone?(text)
      return false unless tone_feature?

      @dark_pattern ||= keyword_pattern(wordlists[:tone_dark])
      @dark_pattern.match?(text)
    end

    def bright_tone?(text)
      return false unless tone_feature?

      @bright_pattern ||= keyword_pattern(wordlists[:tone_bright])
      @bright_pattern.match?(text)
    end

    private

    attr_reader :exclude_patterns, :queneau

    def wordlist?(key)
      wordlist = wordlists[key]
      !wordlist.nil? && !wordlist.empty?
    end

    def keyword_pattern(words)
      options = words.join('|')
      endings = WORD_ENDINGS.join('|')
      pattern = "\\b(?:#{options})(?:#{endings})?\\b"
      Regexp.new(pattern, Regexp::IGNORECASE)
    end
  end
end
