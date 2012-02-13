require "rubygems"
require "cabin"
require "thread"
require "logger"

$: << File.join(File.dirname(__FILE__), "..", "lib")
require "ftw"

agent = FTW::Agent.new

logger = Cabin::Channel.new
queue = Queue.new

# Log to a queue *and* stdout
logger.subscribe(queue)
logger.subscribe(Logger.new(STDOUT))

# Start a thread that takes events from the queue and pushes
# them in JSON format over a websocket.
Thread.new do
  ws = agent.websocket!("http://127.0.0.1:8081/")
  if ws.is_a?(FTW::Response)
    puts "WebSocket handshake failed. Here's the HTTP response:"
    puts ws
    exit 0
  end

  loop do
    event = queue.pop
    ws.publish(event.to_json)
  end
end # websocket publisher thread

while true
  logger.info("Hello world")
  sleep 1
end
