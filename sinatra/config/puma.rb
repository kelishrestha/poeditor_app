workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      "#{Dir.getwd}/config.ru"
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || ENV['SINATRA_ENV'] || 'development'
