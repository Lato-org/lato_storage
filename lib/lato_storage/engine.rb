module LatoStorage
  class Engine < ::Rails::Engine
    isolate_namespace LatoStorage

    initializer 'lato_storage.importmap', before: 'importmap' do |app|
      app.config.importmap.paths << root.join('config/importmap.rb')
    end

    initializer "lato_storage.precompile" do |app|
      app.config.assets.precompile << "lato_storage_manifest.js"
    end
  end
end
