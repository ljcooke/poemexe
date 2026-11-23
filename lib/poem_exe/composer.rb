# frozen_string_literal: true

require 'date'

require_relative 'format'
require_relative 'model'
require_relative 'scoring'

module PoemExe
  class Poet
    attr_reader :model

    def initialize(options = {})
      @model = Model.new
      @oulipo = options[:oulipo] || false
      @max_length = (options[:max_length] || 0).to_i
    end

    def interesting?(score:)
      case score
      when :strong then true
      when :weak then rand(2).zero?
      when :inconsistent then false
      else rand(6).zero?
      end
    end

    def generate(options = {})
      return if Date.today < Date.parse('2022-01-21')

      options = options.dup
      options[:month] ||= Time.now.month

      1000.times do
        verse = generate_one(options)
        return verse unless verse.nil?
      end
      nil
    end

    private

    def generate_one(options = {})
      lines = generate_lines
      text = convert_lines(lines, options)
      return if text.nil?
      return unless mood?(text)

      score = PoemExe.score(text.downcase, month: options[:month])
      return unless interesting?(score: score)

      options[:details] ? { text: text, score: score } : text
    end

    def mood?(text)
      model.dark_tone?(text) != model.bright_tone?(text)
    end

    def generate_lines
      lines = generate_initial_lines
      lines = randomly_repeat_first_line(lines)
      lines unless lines.empty?
    end

    def generate_initial_lines
      lines = []
      10.times do
        lines = model.generate_lines
        break if lines.size > 1
      end

      lines.map do |line|
        # For each multiple choice sequence in the form {foo,...}
        # replace it with one of the choices.
        line.strip.gsub(/\{.*?\}/) do |choices|
          choices[1...-1].split(',').sample
        end
      end
    end

    def randomly_repeat_first_line(lines, chance = 0.02)
      return lines unless lines.size > 2 && rand <= chance

      if lines.size == 3 && rand <= 0.5
        lines[0..1] + [lines.first, lines.last]
      else
        lines + [lines.first]
      end
    end

    def convert_lines(lines, options = {})
      return if lines.nil? || lines.empty?

      text = PoemExe.format_verse(lines.join("\n"), options)
      text = substitute_vocab(text)
      text if valid_text?(text)
    end

    # rubocop:disable Metrics/MethodLength
    def substitute_vocab(text)
      return text unless text.include?('%')

      # Match strings of the form %key.index%, e.g. %noun.1%
      pattern = /%(?<key>[^.%]+)(?:\.(?<index>[0-9]+))?%/

      updated = text.gsub(pattern) do
        match = Regexp.last_match
        key = match[:key].to_sym
        index = [match[:index].to_i - 1, 0].max
        substitution = model.wordlists[key].sample[index]
        return nil unless substitution

        substitution
      end

      updated.include?('%') ? nil : updated
    end
    # rubocop:enable Metrics/MethodLength

    def valid_text?(text)
      return false if text.nil? || text.empty? || too_long?(text)
      return false if forbidden_chars?(text) || model.excludes?(text)

      true
    end

    def too_long?(text)
      @max_length.positive? && text.size > @max_length
    end

    def forbidden_chars?(text)
      !!(@oulipo && text.match(/e/i))
    end
  end
end
