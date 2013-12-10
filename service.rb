require 'rubygems' 
require 'bundler'
Bundler.require

require 'yaml'
require 'thin'

$:.unshift(File.dirname(__FILE__)) 
require 'app.rb'

server = ::Thin::Server.new('127.0.0.1', 8001, App)
server.log_file = 'tmp/thin.log'
server.pid_file = 'tmp/thin.pid'
server.daemonize
server.start