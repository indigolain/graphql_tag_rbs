# frozen_string_literal: true

require "fileutils"
require "graphql_tag_pluck"
require "open3"
require "rake"
require "tmpdir"

# Plucks operations from Ruby files with graphql_tag_pluck, generates RBS with
# the rake task, and checks the result with `rbs validate` and Steep.
RSpec.describe "graphql_tag_rbs end to end" do
  around do |example|
    Dir.mktmpdir do |dir|
      @dir = File.realpath(dir)
      Dir.chdir(@dir) { example.run }
    end
  end

  def write(path, content)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def run_tool(*command)
    output, status = Open3.capture2e(Gem.ruby, "-S", *command)
    [output, status]
  end

  before do
    FileUtils.cp(File.join(GeneratorHelper::FIXTURES, "schema.graphql"), "schema.graphql")
    write("app/clients/user_client.rb", <<~'RUBY')
      module Clients
        class UserClient
          USER_QUERY = <<~GRAPHQL
            query UserQuery($id: ID!) {
              user(id: $id) { id name role createdAt }
            }
          GRAPHQL

          SEARCH_QUERY = <<~GRAPHQL
            query SearchQuery($term: String!) {
              search(term: $term) {
                __typename
                ... on User { name }
                ... on Bot { owner { id } }
              }
            }
          GRAPHQL
        end
      end
    RUBY

    pluck_options = GraphqlTagPluck.options
    rbs_options = GraphqlTagRbs.options
    GraphqlTagPluck.options = pluck_options.merge(file_glob_pattern: File.join(@dir, "app/**/*.rb"), output_path: "operations.json")
    GraphqlTagRbs.options = rbs_options.merge(input_path: "operations.json", output_dir: "sig/graphql", scalars: { "DateTime" => "::String" })

    rake = Rake::Application.new
    Rake.with_application(rake) do
      load Gem.find_files("graphql_tag_pluck/tasks/generate_graphql_operation_list.rake").first
      load File.expand_path("../lib/graphql_tag_rbs/tasks/generate.rake", __dir__)
      expect { rake["graphql_tag_pluck:generate_graphql_operation_list"].invoke }.not_to raise_error
      expect { rake["graphql_tag_rbs:generate"].invoke }.to output(/wrote 2 file\(s\) to sig\/graphql/).to_stdout
    end
  ensure
    GraphqlTagPluck.options = pluck_options
    GraphqlTagRbs.options = rbs_options
  end

  it "writes one file per source file and a shared file" do
    expect(Dir.glob("sig/graphql/**/*.rbs").sort).to eq(["sig/graphql/_shared.rbs", "sig/graphql/app/clients/user_client.rbs"])
    expect(File.read("sig/graphql/app/clients/user_client.rbs"))
      .to include("# query UserQuery at app/clients/user_client.rb:4 (Clients::UserClient::USER_QUERY)")
  end

  it "generates valid RBS that Steep checks code against" do
    output, status = run_tool("rbs", "-I", "sig", "validate")
    expect(status).to be_success, output

    write("sig/api.rbs", <<~RBS)
      module Api
        def self.user: (GraphQLTypes::UserQuery::variables) -> GraphQLTypes::UserQuery::response
        def self.search: (GraphQLTypes::SearchQuery::variables) -> GraphQLTypes::SearchQuery::response
      end
    RBS
    write("lib/app.rb", <<~'RUBY')
      module Api
        def self.user(variables) = raise
        def self.search(variables) = raise
      end

      if (user = Api.user({ "id" => "1" })["data"]&.fetch("user"))
        user["id"].upcase
        user["createdAt"].upcase
        user["name"].upcase
      end

      Api.user({})

      Api.search({ "term" => "x" })["data"]&.fetch("search")&.each do |result|
        result["__typename"] == "User"
      end
    RUBY
    write("Steepfile", <<~RUBY)
      target :app do
        signature "sig"
        check "lib"
      end
    RUBY

    output, = run_tool("steep", "check")
    errors = output.scan(/^lib\/app\.rb:(\d+):\d+: \[error\]/).flatten

    # Only the planted mistakes: calling a method on a nullable field, and a missing required variable.
    expect(errors).to eq(%w[9 12]), output
  end
end
