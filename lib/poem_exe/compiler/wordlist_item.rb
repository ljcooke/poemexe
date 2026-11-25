# frozen_string_literal: true

require 'dry-struct'

require_relative '../types'

module PoemExe
  module Compiler
    class WordlistItem < Dry::Struct
      attribute :tokens, Types::StringArray

      def self.parse(str)
        tokens = str.split('/')
        new(tokens:) unless tokens.empty?
      end

      def to_json(*args) = tokens.to_json(*args)
    end
  end
end
