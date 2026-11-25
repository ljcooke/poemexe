# frozen_string_literal: true

require "dry-types"

module PoemExe
  module Types
    Types = Dry.Types()

    String = Types::String

    Pathname = Types.Instance(::Pathname)
    StringArray = Types::Array.of(Types::String)
  end
end
