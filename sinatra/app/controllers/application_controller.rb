require_relative '../../lib/rails_sanitizer'
require_relative '../../lib/poeditor'
require_relative '../../lib/zip_file_generator'
require 'fileutils'
require 'zip'

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

  get '/bulk_download' do
    begin
      # Updating all files before zip download
      project_directory = "projects_data/#{session[:current_project][:project_id]}"
      FileUtils.mkdir_p(project_directory)
      language_list = session[:project][session[:current_project][:project_id]]
      language_list.each do |lang_details|
        filename = "projects_data/#{session[:current_project][:project_id]}/#{lang_details['code']}.json"
        translation_file = File.new(filename, 'w+')
        options = {
          api_token: session[:current_project][:project_key],
          id: session[:current_project][:project_id],
          language: lang_details['code'],
          type: 'key_value_json'
        }
        file_details = Poeditor.get_language_translation(options)
        translation_file.puts(file_details.to_json)
        translation_file.close
      end

      # Creating zip file
      options = {
        api_token: session[:current_project][:project_key],
        id: session[:current_project][:project_id]
      }
      project_details = Poeditor.get_project_details(options)
      output_filename = "projects_data/#{project_details['name'].gsub(' ','_')}.zip"
      File.delete(output_filename) if File.exist?(output_filename)
      zip_file = ZipFileGenerator.new(project_directory, output_filename)
      zip_file.write()

      send_file(output_filename, type: 'application/zip', disposition: 'attachment', filename: output_filename)
    end
  end

  get '/view_file' do
    code = params['code']
    options = {
      api_token: session[:current_project][:project_key],
      id: session[:current_project][:project_id],
      language: code,
      type: 'key_value_json'
    }
    @file_details = Poeditor.get_language_translation(options)
    erb :view_file
  end
end
