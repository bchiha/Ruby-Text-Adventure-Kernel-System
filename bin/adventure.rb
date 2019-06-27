#!/usr/bin/env ruby

begin
  require '../lib/adventure_kernel_system'
rescue LoadError
  require 'rubygems'
  require '../lib/adventure_kernel_system'
end

begin
	game=Aks::GameEngine.new
	game.run
rescue Exception => e
	puts "Something Bad Happened, Check your csv file. Error is :" << e.message
end
