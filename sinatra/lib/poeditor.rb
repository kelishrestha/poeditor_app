require 'faraday'
require 'faraday/net_http'
require 'uri'
require 'open-uri'

Faraday.default_adapter = :net_http

module Poeditor
  class << self
    BASE_URL = 'https://api.poeditor.com/v2'

    def get_languages_list(params)
      request = Faraday.new(url: BASE_URL)

      response = request.post('languages/list', URI.encode_www_form(params))
      if response.status == 200
        json_response = JSON.parse(response.body)
        json_response['result']['languages']
      else
        # TODO: Escape route
      end
    end

    def get_language_translation(params)
      request = Faraday.new(url: BASE_URL)
      response = request.post('projects/export', URI.encode_www_form(params))
      if response.status == 200
        json_response = JSON.parse(response.body)
        file_url = json_response['result']['url']
        JSON.load(open(file_url))
      end
    end

    def get_project_details(params)
      request = Faraday.new(url: BASE_URL)
      response = request.post('projects/view', URI.encode_www_form(params))
      if response.status == 200
        json_response = JSON.parse(response.body)
        json_response['result']['project']
      end
    end

    def get_all_projects(params)
      request = Faraday.new(url: BASE_URL)
      response = request.post('projects/list', URI.encode_www_form(params))
      if response.status == 200
        json_response = JSON.parse(response.body)
        json_response['result']['projects']
      end
    end

    def get_terms_with_language_code(params)
      request = Faraday.new(url: BASE_URL)
      response = request.post('terms/list', URI.encode_www_form(params))
      if response.status == 200
        json_response = JSON.parse(response.body)
        json_response['result']['terms']
      end
    end

    # Add new term
    def add_new_term(params)
      request = Faraday.new(url: BASE_URL)
      response = request.post('terms/add', URI.encode_www_form(params))
      if response.status == 200
        json_response = JSON.parse(response.body)
        json_response['result']['terms']
      end
    end

    # Delete term
    def delete_term(params)
      request = Faraday.new(url: BASE_URL)
      response = request.post('terms/delete', URI.encode_www_form(params))
      if response.status == 200
        json_response = JSON.parse(response.body)
        json_response['result']['terms']
      end
    end

    def translation_filenames(code)
      case code.to_s.downcase
      when 'zh-cn'
        return 'zh'
      when 'zh-hant'
        return 'zh-TW'
      else
        code
      end
    end
  end
end
