require "rubygems"
require "addressable/uri"
require "thread"

$: << File.join(File.dirname(__FILE__), "lib")
require "ftw/agent"

agent = FTW::Agent.new
#uri = Addressable::URI.parse("http://httpbin.org/ip")
uri = Addressable::URI.parse("http://google.com/")
#uri = Addressable::URI.parse("http://twitter.com/")

request = agent.get(uri)
response = agent.execute(request)
response.read_body do |chunk|
  p chunk[0..30]
end

request = agent.head(uri)
response = agent.execute(request)
response.read_body do |chunk|
  p chunk[0..30]
end
