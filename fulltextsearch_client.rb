#! /usr/bin/ruby

require 'drb/drb' 
require 'jcode'
require 'pp'

$KCODE = 'UTF8'

there = DRbObject.new_with_uri('druby://localhost:12345') 
pp there.search('これは', 0.2, 1, 1) 
#pp there.search('Full', 0.2, 1, 1) 


