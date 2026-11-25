# frozen_string_literal: true

require 'json'

require_relative '../types'
require_relative 'model_builder'

module PoemExe
  module Compiler
    class ModelWriter
      def initialize(model, log: false)
        model_type = Dry.Types().Instance(ModelBuilder)
        @model = model_type[model]
        @log = log
      end

      def write(path, format: nil)
        path = Types::Pathname[path]
        format = format ? format.to_s : path.extname.to_s[1..]
        path.dirname.mkdir unless path.dirname.exist?
        write_format(path, format)
      end

      private

      def write_format(path, format)
        case format
        when 'json' then write_json(path)
        else raise ArgumentError, "Unsupported format: #{format.inspect}"
        end
      end

      def write_json(path)
        data = JSON.pretty_generate(@model.build)
        puts "[#{self.class.name}] Writing #{path}" if @log
        File.open(path, 'w').write(data)
      end
    end
  end
end
