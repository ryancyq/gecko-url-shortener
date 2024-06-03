# frozen_string_literal: true

module UrlSlugEncoder
  CHARS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  CHARS_LOOKUP = CHARS.each_char.with_index.each_with_object({}) do |(char, index), result|
    result[char] = index
  end
  BASE = CHARS.length

  MAX_LENGTH = 15
  MAX_VALUE = (BASE**MAX_LENGTH) - 1
  MAX_CHARS = (Math.log2(MAX_VALUE) / 8).floor

  def self.encode(input)
    intput = input.to_s unless input.is_a?(String)

    str = input&.to_s.presence
    raise ArgumentError, "Encode string can't be blank" if str.blank?
    raise ArgumentError, "Encode string can't be more than #{MAX_CHARS} chars" if str.length > MAX_CHARS

    # read binary data from string in 8-bit unsigned slices
    num = str.to_s.unpack("c*").each_with_index.reduce(0) do |result, (bits, pos)|
      result + (bits << (8 * pos))
    end

    encode_int(num)
  end

  def self.encode_int(num)
    raise ArgumentError, "Encode value must be Integer" unless num.is_a?(Integer)
    return nil if num < 0
    return 0.to_s if num == 0
    raise ArgumentError, "Encode value can't be greater than #{MAX_VALUE}" if num > MAX_VALUE

    result = ""
    while num > 0
      remainder = num % BASE
      result = CHARS[remainder] + result # working backwards from least significant part
      num -= remainder # ensure num is divisible by BASE
      num /= BASE
    end
    result
  end

  def self.decode(input)
    intput = input.to_s unless input.is_a?(String)

    str = input&.to_s.presence
    raise ArgumentError, "Decode string can't be blank" if str.blank?
    raise ArgumentError, "Decode string can't be more than #{MAX_LENGTH} chars" if str.length > MAX_LENGTH

    # decode char from CHARS by summation
    i = 0
    len = str.length - 1
    num = 0
    while i <= len
      pow = BASE**(len - i)
      num += CHARS_LOOKUP[str[i]] * pow
      i += 1
    end

    decode_int(num)
  end

  def self.decode_int(num)
    raise ArgumentError, "Decode value must be Integer" unless num.is_a?(Integer)

    length = (Math.log2(num) / 8).ceil
    length.times.map { |pos| (num >> (8 * pos)) & 255 }.pack("C*")
  end
end
