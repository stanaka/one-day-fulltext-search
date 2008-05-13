#! /usr/bin/ruby

require 'drb/drb' 
require 'jcode'
require 'pp'

$KCODE = 'UTF8'

if ARGV.length < 1 then
  puts "#{$0} word [bcount_factor] [scount_factor] [time_factor]"
  exit
end
word = ARGV[0]
bcount_factor = ARGV.length > 1 ? ARGV[1] : 1
scount_factor = ARGV.length > 2 ? ARGV[2] : 1
time_factor = ARGV.length > 3 ? ARGV[3] : 1

there = DRbObject.new_with_uri('druby://localhost:12345') 
pp there.search(word, bcount_factor, scount_factor, time_factor)


