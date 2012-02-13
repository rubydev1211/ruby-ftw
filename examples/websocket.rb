require "rubygems"
require "addressable/uri"

$: << File.join(File.dirname(__FILE__), "..", "lib")
require "ftw"

agent = FTW::Agent.new
uri = Addressable::URI.parse("ws://127.0.0.1:8081/hello")
#response, connection = agent.upgrade(uri, "websocket", :headers => {
#    "Sec-WebSocket-Key" => "dGhlIHNhbXBsZSBub25jZQ==",
#    "Sec-WebSocket-Version" => "13"
#})
#puts response

ws = agent.websocket!(uri)
#ws.instance_eval { p @connection.read }
ws.publish("Fizzle")
ws.each do |payload|
  p :payload => payload
end
