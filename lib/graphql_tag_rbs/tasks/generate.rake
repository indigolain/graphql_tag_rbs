# frozen_string_literal: true

namespace :graphql_tag_rbs do
  desc "Generate RBS types for the GraphQL operations plucked by graphql_tag_pluck"
  task :generate do
    result = GraphqlTagRbs.generate
    puts "graphql_tag_rbs: wrote #{result.written.size} file(s) to #{GraphqlTagRbs.options[:output_dir]}"
    result.deleted.each { |path| puts "graphql_tag_rbs: removed #{path}" }
  end
end
