# frozen_string_literal: true

class UrlSlugEncoder
  CHARS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  CHARS_LOOKUP = CHARS.each_char.with_index.each_with_object({}) do |(char, index), result|
    result[char] = index
  end
  BASE = CHARS.length
  DEFAULT_SLUG_SIZE = 15

  class << self
    def default
      new(slug_size: DEFAULT_SLUG_SIZE)
    end

    def encode(*)
      default.encode(*)
    end

    def decode(*)
      default.decode(*)
    end
  end

  attr_reader :max_chars, :slug_size, :max_value

  def initialize(slug_size:)
    raise ArgumentError, "slug_size must be positive integer" unless slug_size.is_a?(Integer) && slug_size.positive?

    @slug_size = slug_size
    @max_value = (BASE**slug_size) - 1
    @max_chars = (Math.log2(max_value) / 8).floor
  end

  def encode(input)
    str = input&.to_s.presence
    raise ArgumentError, "Encode string can't be blank" if str.blank?
    raise ArgumentError, "Encode string can't be more than #{max_chars} chars" if str.length > max_chars

    # pad with zeros since we only support number input
    str = str.rjust(max_chars, "0")

    # read binary data from string in 8-bit unsigned slices
    num = str.to_s.unpack("c*").each_with_index.reduce(0) do |result, (bits, pos)|
      result + (bits << (8 * pos))
    end

    encode_int(num)
  end

  def decode(input)
    str = input&.to_s.presence
    raise ArgumentError, "Decode string can't be blank" if str.blank?
    raise ArgumentError, "Decode string can't be more than #{slug_size} chars" if str.length > slug_size

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

  private

  def encode_int(num)
    raise ArgumentError, "Encode value must be Integer" unless num.is_a?(Integer)
    return nil if num.negative?
    return 0.to_s if num.zero?
    raise ArgumentError, "Encode value can't be greater than #{max_value}" if num > max_value

    result = ""
    while num.positive?
      remainder = num % BASE
      result = CHARS[remainder] + result # working backwards from least significant part
      num -= remainder # ensure num is divisible by BASE
      num /= BASE
    end
    result
  end

  def decode_int(num)
    raise ArgumentError, "Decode value must be Integer" unless num.is_a?(Integer)

    length = (Math.log2(num) / 8).ceil
    length.times.map { |pos| (num >> (8 * pos)) & 255 }.pack("C*")
  end
end
