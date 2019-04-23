module Achiever
  class Visibilities
    DEFAULTS = {
      visible: ->(*) { true },
      hidden: ->(*) { false }
    }.freeze

    include Singleton

    def initialize
      @vis = {}

      DEFAULTS.each { |k, v| register(k, &v) }
    end

    def register(name, &block)
      @vis[name.to_sym] = block
    end

    def check(name, *args)
      name = name.to_sym

      raise(Exceptions::InvalidVisiblity, name) unless @vis.key?(name)

      @vis[name].call(*args)
    end
  end
end
