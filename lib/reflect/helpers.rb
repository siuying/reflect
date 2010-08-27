require 'ftools'

module Reflect
  module Helpers

    def config_file
      dir = "#{ENV["HOME"]}/.reflect"
      config = "#{dir}/config.yml"
      
      unless File.exists?(dir)
        puts "Create config file folder: #{dir}"
        File.makedirs(dir)
        
        unless File.exists?(config) 
          source = File.expand_path('../../../config/config.default.yml', __FILE__)
          puts "Copy config file from #{source} to #{config}"
          File.copy(source, config)
        end
      else
        puts "Use config file #{config}"
      end

      return config
    end

    def configure(config_file)
      begin 
        puts "Read config file: #{config_file}"
        raw_config = File.read(config_file)
        config = YAML.load(raw_config)
      rescue
        raise "Cannot read the config file: #{config_file}. Please check if the config file exists!"
      end

      if config.nil? 
        raise "Config file (#{config_file}) not exists!"

      elsif config["twitter"].nil? || config["plurk"].nil?
        raise "Config file (#{config_file}) invalid!"

      elsif config["twitter"]["username"].nil? || config["twitter"]["username"] == "your_username"
        raise "You must configure twitter account in config file first! (#{config_file})"

      elsif config["plurk"]["username"].nil? || config["plurk"]["username"] == "your_username"
        raise "You must configure plurk account in config file first! (#{config_file})"

      elsif config["plurk"]["api"] == "your_plurk_api_key"
        raise "You must set the Plurk API Key in config file first! (#{config_file})"

      else
        return config

      end      
    end

  end
end