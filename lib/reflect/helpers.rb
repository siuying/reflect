module Reflect
  module Helpers
    def read_config(path)
      begin 
        raw_config = File.read(path)
        config = YAML.load(raw_config)

      rescue
        raise "Failed loading config from path: #{path}"
      end
    end
    
    def validate_config(config)
      if config.nil? || config["twitter"].nil?
        return false
      else
        return true
      end      
    end
  end
end