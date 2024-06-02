module UrlSlugEncoder
  CHARS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".freeze
  CHARS_LOOKUP = CHARS.each_char.with_index.inject({}) do |result, (char, index)|
    result[char] = index
    result
  end
  BASE = CHARS.length
  MAX_LENGTH = 15
  MAX_VALUE = BASE**MAX_LENGTH - 1


  def self.encode(base_10_num)
    raise ArgumentError, "Encode value can't be blank" unless base_10_num.present?
    raise ArgumentError, "Encode value must be Integer" unless base_10_num.is_a?(Integer)
    return nil if base_10_num < 0
    return 0.to_s if base_10_num == 0
    raise ArgumentError, "Encode value can't be greater than #{MAX_VALUE}" if base_10_num > MAX_VALUE

    result = ""
    while (base_10_num > 0) do
      result = CHARS[base_10_num % BASE] + result # working backwards from least significant part
      base_10_num /= BASE
    end
    result
  end

  def self.decode(num_string)
    text = num_string&.to_s.presence
    raise ArgumentError, "Decode string can't be blank" if text.blank?
    raise ArgumentError, "Decode string can't be more than #{MAX_LENGTH} chars" if num_string.length > MAX_LENGTH

    i = 0
    len = num_string.length - 1
    result = 0
    while (i <= len) do
      pow = BASE**(len - i)
      result += CHARS_LOOKUP[num_string[i]] * pow
      i += 1
    end
    result
  end
end