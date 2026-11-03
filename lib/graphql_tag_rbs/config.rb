# frozen_string_literal: true

module GraphqlTagRbs
  # Loads options from .graphqltagrbsconfig.yaml in the current directory.
  class Config
    CONFIG_FILE = File.expand_path(".graphqltagrbsconfig.yaml", Dir.pwd)

    def self.load(path = CONFIG_FILE)
      return {} unless File.exist?(path)

      (YAML.load_file(path) || {}).to_h { |key, value| [key.to_sym, value] }
    end
  end
end
