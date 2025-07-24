module LatoStorage
  # Config
  # This class contains the default configuration of the engine.
  ##
  class Config

    # This option allows to optimize performances by skipping count queries.
    # If set to true, it will not perform count queries for collections and use other methods instead.
    # This can significantly speed up operations but may lead to inaccuracies in counts.
    # This is really useful for large datasets where performance is critical.
    # Default is false.
    attr_accessor :optimize_performances

    def initialize
      @optimize_performances = false
    end
  end
end