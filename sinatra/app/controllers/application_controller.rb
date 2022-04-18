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
    options = { api_token: ENV['POEDITOR_TOKEN'] }
    session[:current_project] = { project_key: ENV['POEDITOR_TOKEN'] }
    @projects = Poeditor.get_all_projects(options)
    erb :index, layout: :application_layout
  end

  post '/languages' do
    project_id, project_name = params['project']['id'].to_s.split('|')
    project_key = params['project']['key'] || ENV['POEDITOR_TOKEN']
    options = { api_token: project_key, id: project_id}
    languages = Poeditor.get_languages_list(options)
    session[:project] = { "#{project_id}" => languages }
    session[:current_project] = session[:current_project].merge({
        project_id: project_id,
        project_key: project_key,
        project_name: project_name
      })
      redirect('/language_list')
    end

  get '/language_list' do
    @language_list = session[:project][session[:current_project][:project_id]]
    erb :language_list, layout: :project_layout
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
    erb :view_file, layout: :view_file_layout
  end

  get '/list_terms' do
    languages = session[:project][session[:current_project][:project_id]]
    all_terms = languages.inject({}) do |all_terms, lang_details|
      code = lang_details['code']
      options = {
        api_token: session[:current_project][:project_key],
        id: session[:current_project][:project_id],
        language: code
      }
      all_terms[code] = Poeditor.get_terms_with_language_code(options)
      all_terms
    end
    english_terms = all_terms['en'].collect do |details|
      {
        term: details['term'],
        context: details['context']
      }
    end
    formatted_all_terms = []
    english_terms.each do |terms|
      formatted_term = {}
      formatted_terms = {
        term: terms[:term],
        context: (JSON.parse(terms[:context]) rescue terms[:context])
      }
      translations = {}
      all_terms.each do |code, terms_details|
        translation_detail = terms_details.detect{|detail| detail['term'] == terms[:term] && detail['context'] == terms[:context] }
        translation = { code => translation_detail["translation"]["content"]}
        translations.merge!(translation)
        formatted_term = formatted_terms.merge(translations: translations)
      end
      formatted_all_terms << formatted_term
    end
    @formatted_all_terms = formatted_all_terms
    erb :list_terms, layout: :project_layout
  end
end
