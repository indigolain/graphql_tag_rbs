# frozen_string_literal: true

module GeneratorHelper
  FIXTURES = File.expand_path("../fixtures", __dir__)

  def fixture_schema
    @fixture_schema ||= GraphqlTagRbs::SchemaLoader.load(File.join(FIXTURES, "schema.graphql"))
  end

  # Builds a graphql_tag_pluck-style entry. Sources are parsed and normalized
  # the same way graphql_tag_pluck does.
  def operation(source, file: "app/a.rb", line: 1, constant: nil)
    definition = GraphQL.parse(source).definitions.first
    type = definition.is_a?(GraphQL::Language::Nodes::FragmentDefinition) ? "fragment" : definition.operation_type
    [definition.name || "#{file}:#{line}",
     { "name" => definition.name, "source" => definition.to_query_string, "type" => type, "file" => file, "line" => line, "constant" => constant }]
  end

  def generate(*operations, schema: fixture_schema, **options)
    GraphqlTagRbs::Generator.new(schema: schema, operations: operations.to_h, **options).generate
  end
end
