# frozen_string_literal: true

require_relative "builder"
require_relative "input_path"
require_relative "wordlist_item"

module PoemExe
  module Compiler
    class WordlistsBuilder < Builder
      def initialize(dir:, log: false)
        @dir = Types::Pathname[dir]
        super(log:)
      end

      def build
        @build ||= build_wordlists.tap { log_stats(_1) if @log }
      end

      private

      def build_wordlists
        results = {}
        input_paths.each do |input|
          results[input.key] = read_wordlist(input.path)
        end
        results.freeze
      end

      def input_paths
        @dir
          .glob("**/*.txt")
          .map { InputPath.new(_1) }
          .reject(&:example?)
          .sort_by(&:key)
          .tap { |paths| raise ArgumentError, "Duplicate files" unless InputPath.uniq?(paths) }
      end

      def read_wordlist(path)
        log_info "Processing #{rel_path(path)}"
        File.open(path).readlines.map do |line|
          line = line.split("#", 2).first&.strip
          WordlistItem.parse(line) if line
        end.compact.freeze
      end

      def log_stats(data)
        stats = data.map { |key, wl| "#{key} (#{wl.size})" }.join(", ")
        log_info "Word lists: #{data.size} [#{stats}]"
      end
    end
  end
end
