# frozen_string_literal: true

require_relative "../types"
require_relative "input_error"

module PoemExe
  module Compiler
    class VersesParser
      RE_CONTAINS_URL = %r{https?://}
      RE_WEAK_LINE = / (and|by|from|is|of|that|the|with)\n/im

      TEXT_REPLACEMENTS = [
        # Convert smart quotes
        [ /\u2018|\u2019/, "'" ].freeze,
        [ /\u201C|\u201D/, '"' ].freeze,

        # Remove double quotes
        [ /"/, "" ].freeze,

        # Em dash
        [ /--|\u2013|\B-|-\B|~/, "\u2014" ].freeze,
        [ /\u2014/, " \u2014" ].freeze,

        # Ellipsis
        [ /\.( \.|\.)+/, "\u2026" ].freeze,
        [ /\b \u2026/, "\u2026" ].freeze,

        # Duplicate spaces
        [ / {2,}/, " " ].freeze,
      ].freeze

      attr_reader :credit, :verses

      # Parse a text file and return a Verse array.
      def self.parse(path:)
        new(path:).parse
      end

      def initialize(path:)
        @path = Types::Pathname[path]
      end

      def parse
        reset!
        File.open(@path).readlines.each_with_index do |line, index|
          parse_line(line, index) unless line.start_with?("#")
        end
        complete_verse
        @verses.freeze
      end

      private

      def reset!
        @credit = nil
        @buffer = []
        @verses = Set.new
      end

      def parse_line(line, index)
        line = prepare_input_line(line, index)
        if line.empty?
          complete_verse
        elsif index.zero?
          parse_first_line(line)
        else
          parse_text_line(line, index)
        end
      end

      def parse_first_line(line)
        if line.start_with?("//")
          @credit = line[2..].lstrip
        else
          parse_text_line(line, 0)
        end
      end

      def parse_text_line(line, _index)
        @buffer << line.strip
      end

      def complete_verse
        return if @buffer.empty?

        text = normalize_text(@buffer.join("\n"))
        @buffer = []

        if text.nil?
          return
        elsif RE_WEAK_LINE.match?(text)
          raise InputError, "Weak line in poem: #{text.gsub("\n", ' / ')}"
        end

        verse = Verse.new(text:, credit: @credit)
        @verses.add(verse.freeze)
      end

      def prepare_input_line(line, index)
        line.split("#", 2).first.rstrip.tap do |line|
          raise InputError, "Verse on line #{index + 1} contains a URL" if RE_CONTAINS_URL.match?(line)
        end
      end

      def normalize_text(text)
        text = text.strip.downcase
        TEXT_REPLACEMENTS.each do |pattern, repl|
          text = text.gsub(pattern, repl)
        end
        text unless text.empty?
      end
    end
  end
end
