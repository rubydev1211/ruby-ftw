require "ftw/namespace"

# A web server.
class FTW::Server
  # This class is raised when an error occurs starting the server sockets.
  class ServerSetupFailure < StandardError; end

  private

  # The pattern addresses must match. This is used in FTW::Server#initialize.
  ADDRESS_RE = /^(.*):([^:]+)$/

  # Create a new server listening on the given addresses
  #
  # This method will create, bind, and listen, so any errors during that
  # process be raised as ServerSetupFailure
  #
  # The parameter 'addresses' can be a single string or an array of strings.
  # These strings MUST have the form "address:port". If the 'address' part
  # is missing, it is assumed to be 0.0.0.0
  def initialize(addresses)
    addresses = [addresses] if !addresses.is_a?(Array)
    dns = FTW::DNS.singleton

    @sockets = {}

    failures = []
    # address format is assumed to be 'host:port'
    # TODO(sissel): The split on ":" breaks ipv6 addresses, yo.
    addresses.each |address|
      m = ADDRESS_RE.match(m)
      if !m
        raise InvalidArgument.new("Invalid address #{address.inspect}, spected string with format 'host:port'")
      end
      host, port = m[1..2] # first capture is host, second capture is port

      # Permit address being simply ':PORT'
      host = "0.0.0.0" if host.nil?

      # resolve each hostname, use the first one that successfully binds.
      local_failures = []
      dns.resolve(host).each do |ip|
        family = ip.include?(":") ? Socket::AF_INET6 : Socket::AF_INET
        socket = Socket.new(family, Socket::SOCK_STREAM, 0)
        sockaddr = Socket.pack_sockaddr_in(port, ip)
        begin
          socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
          socket.bind(sockaddr)
          # If we get here, bind was successful
        rescue Errno::EADDRNOTAVAIL => e
          # TODO(sissel): Record this failure.
          local_failures << "Could not bind to #{ip}:#{port}, address not available on this system."
          next
        rescue Errno::EACCES
          # TODO(sissel): Record this failure.
          local_failures << "No permission to bind to #{ip}:#{port}: #{e.inspect}"
          next
        end

        begin
          socket.listen(100)
        rescue Errno::EADDRINUSE
          local_failures << "Address in use, #{ip}:#{port}, cannot listen."
          next
        end

        # Break when successfully listened
        @sockets["#{host}(#{ip}):#{port}"] = socket
        local_failures.clear
        break
      end
      failures += local_failures
    end

    # Abort if there were failures
    raise ServerSetupFailure.new(failures) if failures.any?
  end # def initialize

  # Close the server sockets
  def close
    @sockets.each do |name, socket|
      socket.close
    end
  end # def close

  # Yield FTW::Connection instances to the block as clients connect.
  def each_connection(&block)
    # TODO(sissel): Select on all sockets
    # TODO(sissel): Accept and yield to the block
    while true
      sockets = @sockets.values
      read, write, error = IO.select(sockets, nil, nil, nil)
      read.each do |serversocket|
        socket, addrinfo = serversocket.accept
        connection = FTW::Connection.from_io(socket)
        yield connection
      end
    end
  end # def each_connection

  public(:initialize, :close, :each_connection)
end # class FTW::Server

