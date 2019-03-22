# frozen_string_literal: true

module Achiever
  module Config
    DEFAULT = {
      achievements: {},
      mtime: Time.at(0),
      achievements_file: 'config/achievements.yml'
    }.freeze
    PRIVATE = %i[data mtime].freeze

    class << self
      def append_features(rcvr, names: %i[config configure], prefix: :'')
        methods_for(DEFAULT, rcvr, prefix) +
          names.map do |name|
            # If called with a block, executes the block setting the argument to rcvr,
            # else returns the configuration hash
            rcvr.define_singleton_method(name) do |&block|
              @config ||= Achiever::Config::DEFAULT.dup

              block.nil? ? @config : block.call(rcvr)
            end
          end
      end

      # define convinence methods for each of the configuration paramaters special
      # methods added for parameters that take booleans, e.g. dont_xxxx or xxxx!
      def methods_for(config, rcvr, prefix)
        config.reject { |k, _| PRIVATE.include?(k) }.map do |k, v|
          (case v
           when true, false
             [[:"dont_#{k}", -> { @config[k] = false }],
              [:"do_#{k}",   -> { @config[k] = true }],
              [:"#{k}!",     -> { @config[k] = true }],
              [:"#{k}?",     -> { @config[k] }],
              [:"#{k}=",     lambda { |l|
                unless [TrueClass, FalseClass].include?(l.class)
                  raise TypeError, "expected #{l.inspect} to be a kind_of? Bool (true, or false)"
                end

                @config[k] = l
              }]]
           else
             [[:"#{k}=",     lambda { |l|
                               unless l.is_a?(v.class)
                                 raise TypeError, "expected #{l.inspect} to be a kind_of? #{v.class}"
                               end

                               @config[k] = l
                             }]]
          end +
            [[:"#{k}", -> { @config[k] }]]
          ).map do |meth, body|
            rcvr.define_singleton_method(:"#{prefix}#{meth}", &body)
          end
        end.flatten
      end
    end
  end
end
