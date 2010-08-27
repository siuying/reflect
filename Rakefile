# Rakefile
require 'rubygems'
require 'bundler'
Bundler.require(:default)

Echoe.new('reflect', '0.1.0') do |p|
  p.description    = "Send your Tweets to Plurk"
  p.url            = "http://github.com/siuying/reflect"
  p.author         = "Francis Chong"
  p.email          = "francis@ignition.hk"
  p.executable_pattern  = ["bin/*"]
  p.ignore_pattern = ["config/config.yml", "tmp/*", "pkg/*"]
  p.runtime_dependencies = ["rake", "echoe", "bundler", "twitter-stream", "plurk", "json"]
end
