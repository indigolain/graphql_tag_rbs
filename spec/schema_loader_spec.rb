# frozen_string_literal: true

require "tmpdir"

RSpec.describe GraphqlTagRbs::SchemaLoader do
  let(:sdl) { File.join(GeneratorHelper::FIXTURES, "schema.graphql") }

  it "loads SDL" do
    expect(described_class.load(sdl).get_type("User").graphql_name).to eq("User")
  end

  it "loads introspection JSON, with or without the data wrapper" do
    introspection = GraphQL::Schema.from_definition(File.read(sdl)).as_json

    Dir.mktmpdir do |dir|
      wrapped = File.join(dir, "wrapped.json")
      raw = File.join(dir, "raw.json")
      File.write(wrapped, JSON.generate(introspection))
      File.write(raw, JSON.generate(introspection.fetch("data")))

      expect(described_class.load(wrapped).get_type("UserLookup")).not_to be_nil
      expect(described_class.load(raw).get_type("Role").values.keys).to eq(%w[ADMIN MEMBER])
    end
  end

  it "raises when the schema file is missing" do
    expect { described_class.load("nope.graphql") }.to raise_error(GraphqlTagRbs::Error, /schema not found at nope\.graphql/)
  end
end
