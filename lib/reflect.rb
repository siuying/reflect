path = File.expand_path(File.dirname(__FILE__))
$:.unshift(path) unless $:.include?(path)

module Reflect
end

require 'reflect/helpers'
require 'reflect/reflect'

