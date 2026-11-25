# frozen_string_literal: true

require 'dry-struct'

require_relative '../types'

module PoemExe
  module Compiler
    class Verse < Dry::Struct
      attribute :text, Types::String
      attribute :credit, Types::String.optional

      attr_reader :lines

      def initialize(*args, **kwargs)
        super
        @lines = text.split("\n")
      end

      def to_json(*args) = export.to_json(*args)

      def export
        {
          a: [ lines.first ].compact,
          b: lines[1...-1],
          c: [ lines.last ].compact,
          source: credit,
        }.compact
      end

      def sort_value
        [ text, credit || '' ]
      end
    end
  end
end
