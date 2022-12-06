# frozen_string_literal: true

module RailsSanitizer
  class << self
    def steralize(data)
      @sanitizer = Rails::Html::FullSanitizer.new
      sanitize_now(data)
    end

    private

    def sanitize_hash(myHash)
      myHash.each do |key, value|
        if value.is_a?(Hash)
          sanitize_hash(value)
        else
          myHash[key] = if value.is_a?(Array)
                          sanitize_array(value)
                        else
                          # if value.is_a?(ActionDispatch::Http::UploadedFile)
                          #   value
                          # else
                            @sanitizer.sanitize(value.to_s)
                          # end
                        end
        end
      end
    end

    def sanitize_array(myArray)
      myArray.each do |value|
        if value.is_a?(Array)
          sanitize_array(value)
        else
          if value.is_a?(Hash)
            sanitize_hash(value)
          else
            @sanitizer.sanitize(value.to_s)
          end
        end
      end
    end

    def sanitize_now(data)
      data_class = data.class
      if data_class == Integer
        @sanitizer.sanitize(data.to_s).to_i
      elsif data.is_a?(Hash)
        sanitize_hash(data)
      elsif data.is_a?(Array)
        sanitize_array(data)
      # elsif data.is_a?(ActionDispatch::Http::UploadedFile)
        # data
      else
        begin
          @sanitizer.sanitize(data.to_s)
        rescue StandardError
          data
        end
      end
    end
  end
end
