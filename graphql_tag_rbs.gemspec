# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "graphql_tag_rbs"
  # Read VERSION here rather than requiring lib/graphql_tag_rbs/version.rb:
  # Dependabot evaluates the gemspec without the VERSION file that version.rb reads.
  spec.version = File.read(File.expand_path("VERSION", __dir__)).strip
  spec.authors = ["indigolain"]
  spec.email = ["indigo.lain@gmail.com"]

  spec.summary = "Generates RBS types for GraphQL operations plucked by graphql_tag_pluck"
  spec.description = "Reads the operation list exported by graphql_tag_pluck and a GraphQL schema, " \
    "and writes RBS type aliases for each operation's variables, data, and response."
  spec.homepage = "https://github.com/indigolain/graphql_tag_rbs"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "graphql", "~> 2.0"
end
