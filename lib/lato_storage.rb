require "lato_storage/version"
require "lato_storage/engine"
require "lato_storage/config"

module LatoStorage
  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end
  end
end
