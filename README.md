# For The Web

## Getting Started

For doing client stuff (http requests, etc), you'll want {FTW::Agent}.

For doing server stuff (http serving, etc), you'll want {FTW::Server}. (not implemented yet)

## Overview

net/http is pretty much not good. Additionally, DNS behavior in ruby changes quite frequently.

I primarily want two things in both client and server operations:

* A consistent API with good documentation and tests
* Modern web features: websockets, spdy, etc.

Desired features:

* A HTTP client that acts as a full user agent, not just a single connections. (With connection reuse)
* HTTP and SPDY support.
* WebSockets support.
* SSL/TLS support.
* An API that lets me do what I need.
* Server and Client modes.
* Support for both normal operation and EventMachine would be nice.

For reference:

* [DNS in Ruby stdlib is broken](https://github.com/jordansissel/experiments/tree/master/ruby/dns-resolving-bug), so I need to provide my own DNS api.

## Agent API

### Common case

    agent = FTW::Agent.new

    request = agent.get("http://www.google.com/")
    response = request.execute
    puts response.body.read

    # Simpler
    response = agent.get!("http://www.google.com/").read
    puts response.body.read

### SPDY

SPDY should automatically be attempted. The caller should be unaware.

I do not plan on exposing any direct means for invoking SPDY.

### WebSockets

    # 'http(s)' or 'ws(s)' urls are valid here. They will mean the same thing.
    websocket = agent.websocket!("http://somehost/endpoint")

    websocket.publish("Hello world")
    websocket.each do |message|
      puts :received => message
    end

## Server API

TBD. Will likely surround 'rack'. Need to find out what servers actually can
support HTTP Upgrade.

It's possible the 'cramp' gem supports all the server-side features we need
(except for SPDY, I suppose, which I might be able to contribute upstream)

## Other Projects

Here are some related projects that I have no affiliation with:

* https://github.com/igrigorik/em-websocket - websocket server for eventmachine
* https://github.com/faye/faye - pubsub for the web (includes a websockets implementation)
* https://github.com/lifo/cramp - real-time web framework (async, websockets)
* https://github.com/igrigorik/em-http-request - HTTP client for EventMachine
* https://github.com/geemus/excon - http client library
