# frozen_string_literal: true

require_relative 'format'
require_relative 'queneau'
require_relative 'scoring'

module PoemExe
  class Poet
    def initialize(options = {})
      load_model! path: options.fetch(:model_path, 'model.json')

      @oulipo = options[:oulipo] || false
      @max_length = (options[:max_length] || 0).to_i
    end

    def load_model!(path:)
      JSON.parse(File.read(path), symbolize_names: true).tap do |model|
        @queneau = PoemExe::Queneau.new(model[:verses])
        @wordlists = model[:words]
        @excludes = model[:excludes].map do |rule|
          Regexp.new(rule, Regexp::IGNORECASE)
        end
      end
      true
    end

    def excluded?(poem)
      @excludes.any? { |rule| rule.match(poem) }
    end

    def interesting?(score:)
      case score
      when :strong then true
      when :weak then rand(2) == 0
      when :inconsistent then false
      else rand(6) == 0
      end
    end

    def generate(options = {})
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
      return nil if lines.nil? || lines.empty?

      # Repeat the first line sometimes
      if lines.count > 2 && rand <= 0.05
        if lines.count == 3 && rand <= 0.3
          lines.insert(2, lines[0])
        else
          lines << lines[0]
        end
      end

      text = PoemExe.format_verse(lines.join("\n"), options)
      text = substitute_vocab(text)
      return nil if text.nil? || text.empty? ||
                    (@max_length > 0 && text.length > @max_length) ||
                    (@oulipo && text.match(/e/i)) ||
                    excluded?(text)

      score = PoemExe.score(text.downcase, month: options[:month])
      return nil unless interesting?(score: score)

      if options[:details]
        return { text: text, score: score }
      else
        return text
      end
    end

    def generate_lines
      lines = []
      10.times do
        lines = @queneau.sample.reject { |line| line.nil? || line.strip.empty? }
        break if lines && lines.size > 1
      end

      lines.map do |line|
        # For each multiple choice sequence in the form {foo,...}
        # replace it with one of the choices.
        line.strip.gsub(/\{.*?\}/) do |choices|
          choices[1...-1].split(',').sample
        end
      end
    end

    def substitute_vocab(text)
      return text unless text.include?('%')

      # Match strings of the form %key.index%, e.g. %noun.1%
      pattern = /%(?<key>[^.%]+)(\.(?<index>[0-9]+))?%/

      updated = text.gsub(pattern) do
        match = Regexp.last_match
        key = match[:key].to_sym
        index = [match[:index].to_i - 1, 0].max
        substitution = @wordlists[key].sample()[index]
        return nil unless substitution

        substitution
      end

      updated.include?('%') ? nil : updated
    end
  end
end
