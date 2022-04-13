require_relative '../../lib/rails_sanitizer'
require_relative '../../lib/poeditor'
require 'fileutils'

class ApplicationController < Sinatra::Base
  include Poeditor
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, 'password_security'
  end

  get '/' do
    erb :index
  end

  post '/languages' do
    project_id = params['project']['id']
    project_key = params['project']['key']
    options = { api_token: project_key, id: project_id}
    languages = Poeditor.get_languages_list(options)
    session[:project] = { "#{project_id}" => languages }
    session[:current_project] = { project_id: project_id, project_key: project_key }
    redirect('/language_list')
  end

  get '/language_list' do
    @language_list = session[:project][session[:current_project][:project_id]]
    erb :language_list
  end

  get '/download' do
    code = params['code']
    options = {
      api_token: session[:current_project][:project_key],
      id: session[:current_project][:project_id],
      language: code,
      type: 'key_value_json'
    }
    file_details = Poeditor.get_language_translation(options)
    begin
      FileUtils.mkdir_p("projects_data/#{session[:current_project][:project_id]}")
      filename = "projects_data/#{session[:current_project][:project_id]}/#{code}.json"
      translation_file = File.new(filename, 'w+')
      translation_file.puts(file_details.to_json)
      send_file(translation_file, type: 'application/json', disposition: 'attachment', filename: filename)
      translation_file.close
    end
  end

  # TODO
  get '/bulk_download' do
    filename = 'poeditor.zip'
    temp_file = Tempfile.new(filename)

    begin
      # Updating all files before zip download
      FileUtils.mkdir_p("projects_data/#{session[:current_project][:project_id]}")
      filename = "projects_data/#{session[:current_project][:project_id]}/#{code}.json"
      translation_file = File.new(filename, 'w+')
      translation_file.puts(file_details.to_json)
      send_file(translation_file, type: 'application/json', disposition: 'attachment', filename: filename)
      translation_file.close

      # TODO: Creating zip
      Zip::OutputStream.open(temp_file) { |zos| }

      Zip::File.open(temp_file.path, Zip::File::CREATE) do |zip|

      end

      zip_data = File.read(temp_file.path)
      send_data(zip_data, type: 'application/zip', disposition: 'attachment', filename: filename)
    ensure # important steps below
      temp_file.close
      temp_file.unlink
    end
  end
end
