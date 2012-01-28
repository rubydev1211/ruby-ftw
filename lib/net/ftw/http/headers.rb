require "net/ftw/namespace"
require "net/ftw/crlf"

# HTTP Headers
#
# See RFC2616 section 4.2: <http://tools.ietf.org/html/rfc2616#section-4.2>
class Net::FTW::HTTP::Headers
  include Enumerable
  include Net::FTW::CRLF

  # Make a new headers container. You can pass a hash of 
  public
  def initialize(headers={})
    super()
    @version = 1.1
    @headers = headers
  end # def initialize

  # Set a header field to a specific value.
  # Any existing value(s) for this field are destroyed.
  def set(field, value)
    @headers[field] = value
  end # def set

  # Add a header field with a value.
  #
  # If this field already exists, another value is added.
  # If this field does not already exist, it is set.
  def add(field, value)
    if @headers.include?(field)
      if @headers[field].is_a?(Array)
        @headers[field] << value
      else
        @headers[field] = [@headers[field], value]
      end
    else
      set(field, value)
    end
  end # def add

  # Removes a header entry. If the header has multiple values
  # (like X-Forwarded-For can), you can delete a specific entry
  # by passing the value of the header field to remove.
  #
  #     # Remove all X-Forwarded-For entries
  #     headers.remove("X-Forwarded-For") 
  #     # Remove a specific X-Forwarded-For entry
  #     headers.remove("X-Forwarded-For", "1.2.3.4")
  #
  # If you try to remove a field that doesn't exist, no error will occur.
  # If you try to remove a field value that doesn't exist, no error will occur.
  def remove(field, value=nil)
    if value.nil?
      @headers.delete(field)
    else
      # remove a specific value
      @headers[field].delete(value)
    end
  end # def remove

  # Get a field value. 
  # 
  # This will return:
  #   * String if there is only a single value for this field
  #   * Array of String if there are multiple values for this field
  def get(field)
    return @headers[field]
  end # def get

  # Iterate over headers. Given to the block are two arguments, the field name
  # and the field value. For fields with multiple values, you will receive
  # that same field name multiple times, like:
  #    yield "Host", "www.example.com"
  #    yield "X-Forwarded-For", "1.2.3.4"
  #    yield "X-Forwarded-For", "1.2.3.5"
  def each(&block)
    @headers.each do |field_name, field_value|
      if field_value.is_a?(Array)
        field_value.map { |value| yield field_name, v }
      else
        yield field_name, field_value
      end
    end
  end # end each

  public
  def to_s
    return @headers.collect { |name, value| "#{name}: #{value}" }.join(CRLF) + CRLF
  end # def to_s
end # class Net::FTW::HTTP::Request < Message
