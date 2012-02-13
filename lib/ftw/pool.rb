require "ftw/namespace"
require "thread"

# A simple thread-safe resource pool.
#
# Resources in this pool must respond to 'available?'.
# For best results, your resources should just 'include FTW::Poolable'
#
# The primary use case was as a way to pool FTW::Connection instances.
class FTW::Pool
  def initialize
    # Pool is a hash of arrays.
    @pool = Hash.new { |h,k| h[k] = Array.new }
    @lock = Mutex.new
  end # def initialize

  # Add an object to the pool with a given identifier. For example:
  #
  #     pool.add("www.google.com:80", connection1)
  #     pool.add("www.google.com:80", connection2)
  #     pool.add("github.com:443", connection3)
  def add(identifier, object)
    @lock.synchronize do
      @pool[identifier] << object
    end
    return object
  end # def add

  # Fetch a resource from this pool. If no available resources
  # are found, the 'default_block' is invoked and expected to
  # return a new resource to add to the pool that satisfies
  # the fetch..
  #
  # Example:
  #
  #     pool.fetch("github.com:443") do 
  #       conn = FTW::Connection.new("github.com:443")
  #       conn.secure
  #       conn
  #     end
  def fetch(identifier, &default_block)
    @lock.synchronize do
      object = @pool[identifier].find { |o| o.available? }
      return object if !object.nil?
    end
    # Otherwise put the return value of default_block in the
    # pool and return it.
    return add(identifier, default_block.call)
  end # def fetch
end # class FTW::Pool
