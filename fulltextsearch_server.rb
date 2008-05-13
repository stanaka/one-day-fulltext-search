#! /usr/bin/env ruby

require 'pp'
require 'nkf'
require 'jcode'
require 'lib/tokenize.rb'
require 'drb/drb'

$KCODE = 'UTF8'
uri = "druby://localhost:12345"

class FTSServer
  def initialize
    @tokenize = nil
    @doc = nil
    @docstr = nil

    open("token.idx", "r") {|io|
      @tokenize = Marshal.load(io)
    }
    open("docid.idx", "r") {|io|
      @doc = Marshal.load(io)
    }
    open("docstr.idx", "r") {|io|
      @docstr = Marshal.load(io)
    }
  end

  def truncate(str,pos, len)
    ret = ''
    start_pos = pos - len / 2 > 0 ? pos - len / 2 : 0
    if start_pos > 0 then 
      ret = '...'
    end
    if str.jlength > start_pos + len
      ret += str.each_char[start_pos..(start_pos + len-1)].to_s + '...'
    else
      ret += str.each_char[start_pos..str.jlength].to_s
    end
    ret.gsub!(/[\r\n]/, '')
    return ret
  end

  def search(word, b = 1, s = 1, t = 1)
    @b_factor = b.to_f
    @s_factor = s.to_f
    @t_factor = t.to_f
    puts "word: #{word}, factor b:#{@b_factor}, s:#{@s_factor}, t:#{@t_factor}"
    res = @tokenize.search(word)
    res.sort! {|a,b| score(@doc[b[0]]) <=> score(@doc[a[0]]) }
    #r = res[0]
    puts res.length
    #puts "#{@doc[r[0]][:url]} b#{@doc[r[0]][:bcount]} s#{@doc[r[0]][:scount]}: #{@docstr[r[0]][1..@docstr[r[0]].index("\n", 1)]} #{truncate(@docstr[r[0]],r[1][0], 60)}" if r
    ret = Array.new
    res.each do |r|
      #puts "#{@doc[r[0]][:url]} b#{@doc[r[0]][:bcount]} s#{@doc[r[0]][:scount]}: #{@docstr[r[0]][1..@docstr[r[0]].index("\n", 1)]} #{truncate(@docstr[r[0]],r[1][0], 60)}"
      #ret.push({:url => @doc[r[0]][:url], :bcount => @doc[r[0]][:bcount], :scount => @doc[r[0]][:scount], :title => @docstr[r[0]][1..@docstr[r[0]].index("\n", 1)], :snippet => truncate(@docstr[r[0]],r[1][0], 60)})
      ret.push({:url => @doc[r[0]][:url], :bcount => @doc[r[0]][:bcount], :scount => @doc[r[0]][:scount], :content => @docstr[r[0]], :date => @doc[r[0]][:date]})
      #puts @docstr[r[0]][1..@docstr[r[0]].index("\n", 1)]
    end
    return ret
  end

  def score(node)
    #unless node[:score_bcount]
      bcount = node[:bcount] ? node[:bcount] : 0
      node[:score_bcount] = 1 - @b_factor / (bcount.to_f + 2)
      scount = node[:scount] ? node[:scount] : 0
      node[:score_scount] = 1 - @s_factor / (scount.to_f + 100)
      time = Time.now - node[:date]
      node[:score_time] = 1 / ((time.to_f * @t_factor / 10 ** 9) + 1)
      #puts "scount: #{scount}, score_scount: #{node[:score_scount]}, bcount: #{bcount}, score_bcount: #{node[:score_bcount]}, time: #{time}, score_time: #{node[:score_time]}"
    #end
    return node[:score_bcount] * node[:score_scount] * node[:score_time]
  end

end

#fts = FTSServer.new
#fts.search('Ruby')
#fts.search('はてな')

DRb.start_service(uri, FTSServer.new)
puts DRb.uri
sleep 
