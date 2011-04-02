require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require './config/dependencies'

start_app! :orm => :mongo_mapper