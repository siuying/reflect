require 'reflect'

include Reflect::Helpers

CONFIG = configure(config_file) rescue nil

puts "*** Welcome to Reflect! ***"
puts "To get started, please edit #{config_file} with your twitter and plurk account!"