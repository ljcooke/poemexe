# frozen_string_literal: true

require "json"
require "zlib"

require_relative "../types"
require_relative "model_builder"

module PoemExe
  module Compiler
    class ModelWriter
      def initialize(model, log: false)
        model_type = Dry.Types().Instance(ModelBuilder)
        @model = model_type[model]
        @log = log
      end

      def write(path, format: nil, pretty: false)
        path = Types::Pathname[path]
        format = format ? format.to_s : path.extname.to_s[1..]
        data = export_format(format, pretty:)

        puts "[#{self.class.name}] Writing #{path}" if @log
        path.dirname.mkdir unless path.dirname.exist?
        File.open(path, "wb") { |fp| fp.write(data) }
      end

      private

      def export_format(format, pretty: false)
        case format
        when "json" then export_json(pretty:)
        when "jsonz" then export_jsonz
        else raise ArgumentError, "Unsupported format: #{format.inspect}"
        end
      end

      def export_json(pretty: false)
        if pretty
          JSON.pretty_generate(@model.build)
        else
          @model.build.to_json
        end
      end

      def export_jsonz
        Zlib::Deflate.deflate(export_json)
      end
    end
  end
end
