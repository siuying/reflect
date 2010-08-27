require 'rubygems'
require 'bundler'
require 'open-uri'

Bundler.require(:default)

require 'lib/reflect/helpers'
include Reflect::Helpers

CONFIG = read_config("./config/config.yml")
unless validate_config(CONFIG)
  exit
end

username = CONFIG["twitter"]["username"]
password = CONFIG["twitter"]["password"]

puts "Find user id of #{username}"
data = JSON(open("http://api.twitter.com/1/users/show/#{username}.json").read)
user_id = data["id"] rescue nil
puts " user id = #{user_id}"
puts "start listening user stream ..."

EventMachine::run {
  stream = Twitter::JSONStream.connect(
    :path    => "/1/statuses/filter.json?follow=#{user_id}",
    :auth    => "#{username}:#{password}"
  )

  stream.each_item do |item|
    data = JSON(item)
    from_user = data["user"]["name"] rescue nil
    text = data["text"] rescue nil
    
    if from_user == username && text
      # this is tweet from username
    end
    puts "#{from_user}: #{text}"
  end

  stream.on_error do |message|
	  puts " ERROR: #{message}"
  end

  stream.on_max_reconnects do |timeout, retries|
	  puts " ERROR: max reconnects"
  end

  trap('TERM') {
    stream.stop
    EventMachine.stop if EventMachine.reactor_running?
  }
}


