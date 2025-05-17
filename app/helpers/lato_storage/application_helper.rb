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

  end
end
