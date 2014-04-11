#require File.join(File.expand_path(__FILE__).sub(/\/ftw\/.*/, "/testing"))
require 'ftw/protocol'
require 'stringio'

describe FTW::Protocol do

  class OnlySysread < Struct.new(:io)
    def sysread(*args)
      io.sysread(*args)
    end
  end

  class OnlyRead < Struct.new(:io)
    def read(*args)
      io.read(*args)
    end
  end

  test "reading body via #read" do
    protocol = Object.new
    protocol.extend FTW::Protocol

    output = StringIO.new
    input  = OnlyRead.new( StringIO.new('Some example input') )

    protocol.write_http_body(input, output, false)

    output.rewind
    assert_equal( output.string, 'Some example input')
  end

  test "reading body via #sysread chunked" do
    protocol = Object.new
    protocol.extend FTW::Protocol

    output = StringIO.new
    input  = OnlySysread.new( StringIO.new('Some example input') )

    protocol.write_http_body(input, output, true)

    output.rewind
    assert_equal( output.string, "12\r\nSome example input\r\n0\r\n\r\n")
  end

  test "reading body via #read chunked" do
    protocol = Object.new
    protocol.extend FTW::Protocol

    output = StringIO.new
    input  = OnlyRead.new( StringIO.new('Some example input') )

    protocol.write_http_body(input, output, true)

    output.rewind
    assert_equal( output.string, "12\r\nSome example input\r\n0\r\n\r\n")
  end


end
