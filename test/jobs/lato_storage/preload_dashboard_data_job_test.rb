require "test_helper"

module LatoStorage
  class PreloadDashboardDataJobTest < ActiveJob::TestCase
    setup do
      @original_cache = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      @original_optimize = LatoStorage.config.optimize_performances
      LatoStorage.config.optimize_performances = true
    end

    teardown do
      Rails.cache = @original_cache
      LatoStorage.config.optimize_performances = @original_optimize
    end

    test "computes data and releases the semaphore" do
      data = PreloadDashboardDataJob.perform_now

      assert_equal 0, data[:blobs_count]
      assert_not data[:computing]
      assert_not_nil data[:generated_at]
      assert_nil Rails.cache.read(PreloadDashboardDataJob::SEMAPHORE_CACHE_KEY)
      assert_equal data, Rails.cache.read(PreloadDashboardDataJob::DATA_CACHE_KEY)
    end

    test "returns default data flagged as computing when locked without cached data" do
      Rails.cache.write(PreloadDashboardDataJob::SEMAPHORE_CACHE_KEY, true)

      data = PreloadDashboardDataJob.perform_now

      assert data[:computing]
      assert_equal 0, data[:blobs_count]
      assert_equal [], data[:content_types]
    end

    test "returns default data flagged as error when calculation fails" do
      job = PreloadDashboardDataJob.new
      job.define_singleton_method(:load_data_with_optimizations) { raise "boom" }

      data = job.perform_now

      assert data[:error]
      assert_equal 0, data[:total_storage]
      assert_nil Rails.cache.read(PreloadDashboardDataJob::SEMAPHORE_CACHE_KEY)
    end

    test "lock is atomic" do
      Rails.cache.write(PreloadDashboardDataJob::SEMAPHORE_CACHE_KEY, true)
      assert_not Rails.cache.write(PreloadDashboardDataJob::SEMAPHORE_CACHE_KEY, true, unless_exist: true)
    end
  end
end
