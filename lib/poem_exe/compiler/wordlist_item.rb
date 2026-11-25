# frozen_string_literal: true

require 'dry-struct'
require 'forwardable'

require_relative '../types'

module PoemExe
  module Compiler
    class WordlistItem < Dry::Struct
      attribute :tokens, Types::StringArray

      extend Forwardable
      def_delegators :tokens, :to_json

      def self.parse(str)
        tokens = str.split('/')
        new(tokens:) unless tokens.empty?
      end
    end
  end
end
