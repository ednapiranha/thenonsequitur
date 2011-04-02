require 'sinatra/base'
require 'yaml'
require 'haml'

module Sinatra
  module Dependencies
    set :haml, :format => :html5
    DEFAULT_DEPENDENCIES = [:yaml, :json]
    
    def load_dependencies(*args)
      (args + DEFAULT_DEPENDENCIES).uniq.each do |lib|
        begin
          require lib.to_s

        rescue LoadError
          puts "== Unable to load dependency - #{lib}"
          exit 0
        end
      end
      puts "== Loaded dependencies: #{(args + DEFAULT_DEPENDENCIES).uniq.join(', ')}"
    end
    
    def start_app!( parameters = {} )
      required_dependencies = parameters[:libs] ||= []
      config_file = parameters[:config_file] ||= 'config/config.yml'
      orm_name = parameters[:orm] ||= false
      

      # Load configuration
      config = YAML.load_file(config_file)
      
      # Setup log file if required
      if config["logging"] == true
        log = File.new(config['log_file'], 'a+')
        $stderr.reopen(log)
      end
      
      # Load default gems
      load_dependencies *((required_dependencies + config['required_dependencies'].to_s.split(',').collect(&:strip)).uniq)

      # Setup default options
      
      set :environment, config['environment'] ||= ENV['RACK_ENV']
      set :server, config["server"]
      set :host, config["host"]
      set :port, config["port"].to_i
      set :views, 'app/views'
      set :public, 'public'

      enable :sessions, :logging, :dump_errors, :raise_errors, :static
      
			if !orm_name
        puts "== No ORM loaded"
      else
        begin
          puts "== ORM selected: #{orm_name}"
          require File.dirname(__FILE__) + "/orms/#{orm_name}" 
        rescue LoadError
          puts "Could not find an ORM extention in config/orms for '#{orm_name}'"
          exit 0
        end
      end

      # load defaults and configuration
      load 'config/configures.rb'
      load "config/default_routes.rb"
  
      # Load models, controllers an helpers
      Dir.glob("app/controllers/**/*.rb") {|file| load file}
      Dir.glob("app/models/**/*.rb") {|file| load file}
      Dir.glob("app/helpers/**/*.rb") {|file| load file}
    end
  end
  
  register Dependencies
end