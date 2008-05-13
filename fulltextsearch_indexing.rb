#! /usr/bin/env ruby

require 'pp'
require 'jcode'
require 'lib/tokenize.rb'
require 'yaml'

$KCODE = 'UTF8'
target_file = 'sample.yaml'

tokenize = Tokenize.new
doc = Hash.new
docstr = Hash.new

dat = Hash.new
docid = 1
dat = YAML.load_file(target_file)
dat.each do |d|
  doc[docid] = { :url => d['url'], :bcount => d['bcount'], :scount => d['scount'], :date => d['date'] }
  docstr[docid] = d['content']
  tokenize.tokenize(docstr[docid], docid)
  docid += 1
end

open("token.idx", "w") {|io|
  Marshal.dump(tokenize, io)
}
open("docid.idx", "w") {|io|
  Marshal.dump(doc, io)
}
open("docstr.idx", "w") {|io|
  Marshal.dump(docstr, io)
}

