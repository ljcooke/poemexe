# frozen_string_literal: true

require "forwardable"
require "json"

require_relative "../types"

module PoemExe
  module Compiler
    class Builder
      extend Forwardable
      def_delegators :build, :to_json

      def initialize(log:)
        @log = log
      end

      def build = raise NotImplementedError

      protected

      def log_info(message)
        puts "[#{self.class.name}] #{message}" if @log
      end

      def log_warn(message)
        warn "[#{self.class.name}] #{message}" if @log
      end

      def rel_path(path)
        path # TODO: Shortest path relative to PWD
      end
    end
  end
end
