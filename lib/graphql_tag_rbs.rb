# frozen_string_literal: true

require "graphql"
require "json"
require "set"
require "yaml"

require_relative "graphql_tag_rbs/version"

module GraphqlTagRbs
  class Error < StandardError; end
end

require_relative "graphql_tag_rbs/config"
require_relative "graphql_tag_rbs/types"
require_relative "graphql_tag_rbs/schema_loader"
require_relative "graphql_tag_rbs/generator"
require_relative "graphql_tag_rbs/writer"
require_relative "graphql_tag_rbs/railtie" if defined?(Rails::Railtie)

module GraphqlTagRbs
  class << self
    attr_accessor :options

    def default_options
      {
        schema_path: "schema.graphql",
        input_path: "__generated__/graphql_operation_list.json",
        output_dir: "sig/graphql",
        namespace: "GraphQLTypes",
        key_style: "string",
        scalars: {}
      }
    end

    # Reads the schema and the graphql_tag_pluck operation list, and writes
    # RBS files into output_dir. Returns the Writer::Result.
    def generate(options = self.options)
      input_path = options[:input_path]
      unless File.exist?(input_path)
        raise Error, "Operation list not found at #{input_path}. " \
          "Run `rake graphql_tag_pluck:generate_graphql_operation_list` first."
      end

      files = Generator.new(
        schema: SchemaLoader.load(options[:schema_path]),
        operations: JSON.parse(File.read(input_path)),
        namespace: options[:namespace],
        key_style: options[:key_style],
        scalars: options[:scalars] || {}
      ).generate

      Writer.new(options[:output_dir]).write(files)
    end
  end

  self.options = default_options.merge(Config.load)
end
