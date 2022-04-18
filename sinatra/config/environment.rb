require 'bundler'
require 'dotenv'
Dotenv.load('.env.development.local', '.env')

Bundler.require
require_all 'app'
