require 'sinatra/base'
require 'mongo_mapper'
 
module Sinatra
  module MongoMapperExtension
    def self.registered(app)
      
      database_config = YAML.load_file('config/database.yml')[app.environment.to_s]
      
      app.set :mongo_host, database_config['host'] || 'localhost'
      app.set :mongo_db, database_config['database']
      app.set :mongo_port, database_config['port'] || Mongo::Connection::DEFAULT_PORT
      # app.set :mongo_user, database_config['username']
      # app.set :mongo_password, database_config['password']
 
      MongoMapper.connection = Mongo::Connection.new(app.mongo_host, app.mongo_port)
      MongoMapper.database = app.mongo_db

      # MongoMapper.database.authenticate(app.mongo_user, app.mongo_password) if app.mongo_use
      
      if defined?(PhusionPassenger)
        PhusionPassenger.on_event(:starting_worker_process) do |forked|
          MongoMapper.connection.connect if forked
        end
      end

      puts "== Connected to a Mongo db '#{app.mongo_db}' on '#{app.mongo_host}:#{app.mongo_port}'"
    end
  end
 
  register MongoMapperExtension
end