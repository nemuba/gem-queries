module Queries
  class Engine < ::Rails::Engine
    isolate_namespace Queries

    config.paths.add "app/queries", eager_load: true

    config.eager_load_paths << Queries::Engine.root.join("lib")

    # load all migrations from the engine
    initializer :append_migrations do |app|
      if app.root.to_s !~ /#{root}/
        config.paths["db/migrate"].expanded.each do |migration_path|
          app.config.paths["db/migrate"] << migration_path
        end
      end
    end
  end
end
