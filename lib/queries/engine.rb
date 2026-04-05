module Queries
  class Engine < ::Rails::Engine
    isolate_namespace Queries

    config.paths.add "app/queries", eager_load: true

    config.eager_load_paths << Queries::Engine.root.join("lib")
  end
end
