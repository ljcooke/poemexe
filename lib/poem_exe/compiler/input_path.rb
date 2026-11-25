# frozen_string_literal: true

require_relative "../types"

module PoemExe
  module Compiler
    class InputPath
      attr_reader :path, :key

      def self.uniq?(paths)
        keys = paths.map(&:key)
        Set.new(keys).size == paths.size
      end

      def initialize(path)
        @path = Types::Pathname[path]
        @key = path.basename(".*").to_s
      end

      def example? = key.end_with?(".example")
    end
  end
end
