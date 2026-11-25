# frozen_string_literal: true

require_relative "builder"
require_relative "excludes_builder"
require_relative "verses_builder"
require_relative "wordlists_builder"

module PoemExe
  module Compiler
    class ModelBuilder < Builder
      def initialize(dir:, log: false)
        @dir = Types::Pathname[dir]
        super(log:)
      end

      def build
        @build ||= build_model
      end

      def excludes
        @excludes ||= ExcludesBuilder.new(path: @dir.join("excludes.txt"), log: @log)
      end

      def verses
        @verses ||= VersesBuilder.new(dir: @dir.join("sources"), log: @log)
      end

      def wordlists
        @wordlists ||= WordlistsBuilder.new(dir: @dir.join("wordlists"), log: @log)
      end

      private

      def build_model
        log_info "Building model"
        {
          excludes: excludes.build,
          verses: verses.build,
          words: wordlists.build,
        }.freeze
      end
    end
  end
end
