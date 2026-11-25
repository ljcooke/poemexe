# frozen_string_literal: true

require_relative "builder"
require_relative "input_path"
require_relative "wordlist_item"

module PoemExe
  module Compiler
    class ExcludesBuilder < Builder
      def initialize(path:, log: false)
        @path = Types::Pathname[path]
        super(log:)
      end

      def build
        @build ||= read_excludes.tap { log_stats(_1) if @log }
      end

      private

      def read_excludes
        log_info "Processing #{rel_path(@path)}"
        File.open(@path).readlines.map do |line|
          line = line.split("#", 2).first&.strip
          line unless line.nil? || line.empty?
        end.compact.freeze
      end

      def log_stats(data)
        log_info "Exclude rules: #{data.size}"
      end
    end
  end
end
