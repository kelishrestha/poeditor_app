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
  end
end
