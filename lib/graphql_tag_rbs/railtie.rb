# frozen_string_literal: true

require "rails"

module GraphqlTagRbs
  class Railtie < Rails::Railtie
    railtie_name :graphql_tag_rbs

    rake_tasks do
      Dir.glob(File.expand_path("tasks/**/*.rake", __dir__)).each { |f| load f }
    end
  end
end
