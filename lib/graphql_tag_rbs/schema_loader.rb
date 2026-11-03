# frozen_string_literal: true

module GraphqlTagRbs
  # Loads a schema from SDL (.graphql / .graphqls) or an introspection result (.json).
  module SchemaLoader
    def self.load(path)
      raise Error, "GraphQL schema not found at #{path}" unless File.exist?(path)

      if File.extname(path) == ".json"
        introspection = JSON.parse(File.read(path))
        # Accept both a raw `{ "__schema": ... }` and a full `{ "data": { "__schema": ... } }` response.
        introspection = { "data" => introspection } if introspection.key?("__schema")
        GraphQL::Schema.from_introspection(introspection)
      else
        GraphQL::Schema.from_definition(File.read(path))
      end
    end
  end
end
