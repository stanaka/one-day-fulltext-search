require 'pp'

class Tokenize
  def initialize
    @tokens = Hash.new
  end

  def add_token(token, docid, position)
    @tokens[token] ||= Hash.new
    @tokens[token][docid] ||= Array.new
    @tokens[token][docid].push position
  end

  def tokenize(str, docid)
    last_char = nil
    sb_word = nil
    position = 0
    str.each_char do |char|
      position += 1
      if char.mbchar?
        if sb_word
          add_token(sb_word, docid, position);
          sb_word = nil
        end
        add_token(last_char + char, docid, position) if last_char
        last_char = char
      else
        last_char = nil
        if char =~ /[!@\#\$\%^&*\(\)\[\]\s\'\"\;\:\.\,\/\\\|\~\>\<]/ then
          if sb_word
            add_token(sb_word, docid, position)
            sb_word = nil
          end
        else
          sb_word = '' unless sb_word
          sb_word += char
        end
      end
    end
  end

  def merge_results(result_set, new_result, offset)
    new_result_set = Hash.new
    merged_keys = result_set.keys & new_result.keys
    merged_keys.each do |key|
      positions = result_set[key] & new_result[key].map {|v| v - offset}
      if positions.length > 0
        new_result_set[key] = positions
      end
    end
    return new_result_set
  end    

  def recursive_search(words, result_set = nil, offset = 0)
    word = words.shift
    if @tokens[word]
      if result_set then
        result_set = merge_results(result_set, @tokens[word], offset)
      else
        result_set = @tokens[word]
      end
      result_set = recursive_search(words, result_set, offset + 1) if words.length > 0
    end
    return result_set
  end

  def search(word)
    results = Array.new
    result_set = nil
    if word.mbchar? && word.jlength > 2 then
      last_char = nil
      words = Array.new
      word.each_char do |char|
        words.push(last_char + char) if last_char
        last_char = char
      end
      result_set = recursive_search(words)
    else
      result_set = @tokens[word]
    end
    if result_set
      #pp result_set
      result_set.each do |docid, positions|
        results.push([docid, positions])
      end
    end
    return results
  end

  def dump
    @tokens
  end
end

