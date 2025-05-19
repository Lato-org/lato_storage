module LatoStorage
  module ApplicationHelper

    def format_bytes(bytes)
      return '0 B' if bytes.nil? || bytes == 0
      
      units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB']
      exponent = (Math.log(bytes) / Math.log(1024)).to_i
      exponent = [exponent, units.size - 1].min
      
      converted = bytes.to_f / (1024 ** exponent)
      "#{format('%.2f', converted)} #{units[exponent]}"
    end

    def active_storage_blob_byte_size(blob)
      format_bytes blob.byte_size
    end

    def active_storage_blob_created_at(blob)
      blob.created_at.strftime('%Y-%m-%d %H:%M:%S')
    end

    def active_storage_blob_filename(blob)
      link_to blob.filename, main_app.url_for(blob), target: '_blank', class: 'text-truncate d-block', style: 'max-width: 250px;'
    end

    def active_storage_attachment_created_at(attachment)
      attachment.created_at.strftime('%Y-%m-%d %H:%M:%S')
    end

    def active_storage_attachment_record_id(attachment)
      "#{attachment.record_type}##{attachment.record_id}"
    end

    def active_storage_attachment_blob_id(attachment)
      return  ' - ' if attachment.blob.nil?
      link_to attachment.blob.filename, main_app.url_for(attachment.blob), target: '_blank', class: 'text-truncate d-block', style: 'max-width: 250px;'
    end

  end
end
