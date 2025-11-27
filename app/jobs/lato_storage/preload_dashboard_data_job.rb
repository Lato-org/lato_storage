module LatoStorage
  class PreloadDashboardDataJob < ApplicationJob
    SEMAPHORE_CACHE_KEY = 'LatoStorage::PreloadDashboardDataJob/semaphore'
    DATA_CACHE_KEY = 'LatoStorage::PreloadDashboardDataJob/data'

    def perform(force_execution = false)
      return load_data_without_optimizations unless LatoStorage.config.optimize_performances
      
      data = Rails.cache.read(DATA_CACHE_KEY)
      return data || {} if Rails.cache.read(SEMAPHORE_CACHE_KEY)

      if data && !force_execution
        LatoStorage::PreloadDashboardDataJob.perform_later(true)
        return data
      end

      Rails.cache.write(SEMAPHORE_CACHE_KEY, true, expires_in: 30.minutes)
      data = load_data_with_optimizations
      Rails.cache.write(DATA_CACHE_KEY, data, expires_in: 12.hours)
      return data
    rescue StandardError => e
      Rails.logger.error "Error in LatoStorage::PreloadDashboardDataJob: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      Rails.cache.delete(SEMAPHORE_CACHE_KEY)
      nil
    end

    private

    # Non-optimized data loading method
    # NOTE: More precise but can be slow on large datasets
    ######################################################################################################

    def load_data_without_optimizations
      blobs_count = ActiveStorage::Blob.count
      attachments_count = ActiveStorage::Attachment.count
      variant_records_count = defined?(ActiveStorage::VariantRecord) ? ActiveStorage::VariantRecord.count : 0
      deletable_blobs_count = ActiveStorage::Blob.left_joins(:attachments).where(active_storage_attachments: { blob_id: nil }).where('active_storage_blobs.created_at < ?', 12.hours.ago).count
      total_storage = ActiveStorage::Blob.sum(:byte_size)
      avg_storage = blobs_count.positive? ? total_storage / blobs_count : 0
      content_types = ActiveStorage::Blob.group(:content_type).count.sort_by { |_, count| -count }.first(5)
      
      largest_blobs = ActiveStorage::Blob.order(byte_size: :desc).limit(3).map do |blob|
        {
          id: blob.id,
          filename: blob.filename.to_s,
          byte_size: blob.byte_size,
          created_at: blob.created_at,
          content_type: blob.content_type,
          service_name: blob.service_name,
          checksum: blob.checksum,
          url: Rails.application.routes.url_helpers.rails_blob_url(blob, only_path: true, expires_in: 12.hours)
        }
      end

      {
        blobs_count: blobs_count,
        attachments_count: attachments_count,
        variant_records_count: variant_records_count,
        deletable_blobs_count: deletable_blobs_count,
        total_storage: total_storage,
        avg_storage: avg_storage,
        content_types: content_types,
        largest_blobs: largest_blobs
      }
    end

    # Optimized data loading method
    # NOTE: Less precise but faster on large datasets
    ######################################################################################################

    def load_data_with_optimizations
      blobs_count = blobs_count_loader
      attachments_count = attachments_count_loader
      variant_records_count = variant_records_count_loader
      deletable_blobs_count = deletable_blobs_count_loader
      total_storage = total_storage_loader(blobs_count)
      avg_storage = blobs_count.positive? ? total_storage / blobs_count : 0
      content_types = content_types_loader

      {
        blobs_count: blobs_count,
        attachments_count: attachments_count,
        variant_records_count: variant_records_count,
        deletable_blobs_count: deletable_blobs_count,
        total_storage: total_storage,
        avg_storage: avg_storage,
        content_types: content_types,
        largest_blobs: []
      }
    end

    def blobs_count_loader
      if ActiveRecord::Base.connection.adapter_name.downcase.include?('mysql')
        result = ActiveRecord::Base.connection.execute('SELECT TABLE_ROWS FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = \'active_storage_blobs\'')
        result.first['TABLE_ROWS'].to_i
      elsif ActiveRecord::Base.connection.adapter_name.downcase.include?('postgresql')
        result = ActiveRecord::Base.connection.execute('SELECT reltuples::BIGINT AS estimate FROM pg_class WHERE relname = \'active_storage_blobs\'')
        result.first['estimate'].to_i
      else
        ActiveStorage::Blob.count
      end
    end

    def attachments_count_loader
      if ActiveRecord::Base.connection.adapter_name.downcase.include?('mysql')
        result = ActiveRecord::Base.connection.execute('SELECT TABLE_ROWS FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = \'active_storage_attachments\'')
        result.first['TABLE_ROWS'].to_i
      elsif ActiveRecord::Base.connection.adapter_name.downcase.include?('postgresql')
        result = ActiveRecord::Base.connection.execute('SELECT reltuples::BIGINT AS estimate FROM pg_class WHERE relname = \'active_storage_attachments\'')
        result.first['estimate'].to_i
      else
        ActiveStorage::Attachment.count
      end
    end

    def variant_records_count_loader
      return 0 unless defined?(ActiveStorage::VariantRecord)

      if ActiveRecord::Base.connection.adapter_name.downcase.include?('mysql')
        result = ActiveRecord::Base.connection.execute('SELECT TABLE_ROWS FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = \'active_storage_variant_records\'')
        result.first['TABLE_ROWS'].to_i
      elsif ActiveRecord::Base.connection.adapter_name.downcase.include?('postgresql')
        result = ActiveRecord::Base.connection.execute('SELECT reltuples::BIGINT AS estimate FROM pg_class WHERE relname = \'active_storage_variant_records\'')
        result.first['estimate'].to_i
      else
        ActiveStorage::VariantRecord.count
      end
    end

    def deletable_blobs_count_loader
      count = 0
      ActiveStorage::Blob.left_joins(:attachments).where(active_storage_attachments: { blob_id: nil }).where('active_storage_blobs.created_at < ?', 12.hours.ago).find_each(batch_size: 1000) do |blob|
        count += 1
      end
      count
    end

    # Estimate the total storage by multiplying average size of a group sample by total blobs count
    def total_storage_loader(blobs_count)
      sample_size = 1000
      total_size = 0
      sampled_count = 0

      ActiveStorage::Blob.order('RANDOM()').limit(sample_size).each do |blob|
        total_size += blob.byte_size
        sampled_count += 1
      end

      return 0 if sampled_count == 0

      average_size = total_size / sampled_count
      average_size * blobs_count
    end

    # Estimate content types by sampling blobs
    def content_types_loader
      content_type_counts = Hash.new(0)
      sample_size = 5000
      sampled_count = 0

      ActiveStorage::Blob.order('RANDOM()').limit(sample_size).each do |blob|
        content_type_counts[blob.content_type] += 1
        sampled_count += 1
      end

      return [] if sampled_count == 0

      # Scale counts to estimated total blobs count
      content_type_counts.transform_values! { |count| (count.to_f / sampled_count) * blobs_count_loader }
      content_type_counts.sort_by { |_, count| -count }.first(5)
    end
  end
end
