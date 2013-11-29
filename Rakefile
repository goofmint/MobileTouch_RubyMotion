# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'rubygems'
require 'motion-cocoapods'
require 'nano-store'
begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'mobiletouch'
  app.pods do
    pod 'GHMarkdownParser'
    pod 'NanoStore', '~> 2.6.0'
  end
end
