class << Org::Antlr::Runtime::DFA
  def unpack_encoded_string(encoded_string)
    data = []
    i = 0
    while i < encoded_string.length
      data.fill RJava.cast_to_short(encoded_string.char_at(i + 1)), data.size, encoded_string.char_at(i).to_i
      i += 2
    end
    data
  end
  
  def unpack_encoded_string_to_unsigned_chars(encoded_string)
    data = []
    i = 0
    while i < encoded_string.length
      data.fill encoded_string.char_at(i + 1), data.size, encoded_string.char_at(i).to_i
      i += 2
    end
    data
  end
end
