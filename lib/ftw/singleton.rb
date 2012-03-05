require "ftw/namespace"

# A mixin that provides singleton-ness
#
# Usage:
#
#     class Foo
#       extend FTW::Singleton
#
#       ...
#     end
#
# foo = Foo.singleton
module FTW::Singleton
  def self.included(klass)
    raise ArgumentError.new("In #{klass.name}, you want to use 'extend #{self.name}', not 'include ...'")
  end # def included

  # Create a singleton instance of this class.
  def singleton
    @instance ||= self.new
    return @instance
  end # def self.singleton
end # module FTW::Singleton

