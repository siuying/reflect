require 'open-uri'
require 'logger'

require 'rubygems'
require 'rake'
require 'twitter/json_stream'
require 'plurk'
require 'json'

module Reflect
  class Main
    attr_accessor :logger, :config, :send_retweet
    
    def initialize(config, logger = Logger.new($stdout))
      @logger = logger
      @config = config

      @send_retweet = config["plurk_retweet"]
      @twitter_auth = "#{config["twitter"]["username"]}:#{config["twitter"]["password"]}"

      @logger.info "Fetch twitter userid of user: #{config["twitter"]["username"]}"
      @user_id   = userid_from_username(config["twitter"]["username"])

      @logger.info "Login to plurk"
      @plurk = init_plurk(config["plurk"]["api"], config["plurk"]["username"], config["plurk"]["password"])
    end
    
    def listen
      #### Start Listening Twitter Streams ####
      @logger.info "Start listening user stream of (#{@user_id})..."
      EventMachine::run {
        stream = Twitter::JSONStream.connect(
          :path    => "/1/statuses/filter.json?follow=#{@user_id}",
          :auth    => @twitter_auth
        )

        stream.each_item do |item|
          data                = JSON(item)          
          from_user           = data["user"]["screen_name"] rescue nil
          text                = data["text"] rescue nil
          in_reply_to_user_id = data["in_reply_to_user_id"] rescue nil
          retweeted_status    = data["retweeted_status"] rescue nil
          delete              = data["delete"] rescue nil

          if from_user == @config["twitter"]["username"] && text
            if in_reply_to_user_id || delete || (!send_retweet && retweeted_status)
              @logger.debug " skipped, this is a reply, delete or retweet"
            else
              @logger.info "Plurk: #{text}"
              @plurk.plurk_add :content => text, :qualifier => "says"
            end
          end
        end

        stream.on_error do |message|
      	  @logger.error message
        end

        stream.on_max_reconnects do |timeout, retries|
      	  @logger.error "max reconnects reached: timeout: #{timeout}, retries: #{retries}"

      	  # reconnect after 15 minutes
      	  stream.stop
      	  sleep(900)
      	  stream = Twitter::JSONStream.connect(
            :path    => "/1/statuses/filter.json?follow=#{@user_id}",
            :auth    => @twitter_auth
          )
        end

        trap('TERM') {
          @logger.info "stopping client"
          stream.stop
          EventMachine.stop if EventMachine.reactor_running?
        }
      }
    end
    
    private
    # Find twitter userid from twitter username
    def userid_from_username(username)
      data = JSON(open("http://api.twitter.com/1/users/show/#{username}.json").read)
      data["id"]
    end
    
    # create plurk api and login
    def init_plurk(api, username, password)
      plurk = Plurk::Client.new api
      plurk.login :username => username, :password => password
      plurk
    end
  end
end