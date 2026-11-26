# frozen_string_literal: true

require_relative "builder"
require_relative "input_path"
require_relative "verse"
require_relative "verses_parser"

module PoemExe
  module Compiler
    class VersesBuilder < Builder
      def initialize(dir:, log: false)
        @dir = Types::Pathname[dir]
        super(log:)
      end

      def build
        @build ||= build_verses.tap { log_stats(_1) if @log }
      end

      private

      def build_verses
        results = Set.new

        input_paths.each do |input|
          verses_in_file(input.path).each do |verse|
            log_warn "Duplicate: #{verse.text.inspect}" if results.include?(verse)
            results.add(verse)
          end
        end

        results.sort_by(&:sort_value).freeze
      end

      def input_paths
        @dir
          .glob("**/*.txt")
          .sort
          .map { InputPath.new(_1) }
          .reject(&:example?)
      end

      def verses_in_file(path)
        log_info "Processing #{path.basename}"
        VersesParser.parse(path:)
      end

      def log_stats(data)
        log_info "Verses: #{data.size}"
      end
    end
  end
end
