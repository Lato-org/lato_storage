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

    # Lifetime of the signed links to blobs shown in the panel.
    # Links are generated on every page render (or cached with the dashboard data), so keep it short.
    # Default is 12 hours.
    attr_accessor :blob_url_expires_in

    def initialize
      @optimize_performances = false
      @blob_url_expires_in = 12.hours
    end
  end
end