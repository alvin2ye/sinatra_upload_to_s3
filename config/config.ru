require 'rubygems'
require 'bundler'
require 'yaml'
Bundler.require
$:.unshift(File.dirname(__FILE__) + "/../") 

require 'app.rb'
run App