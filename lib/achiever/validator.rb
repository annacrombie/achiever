module Achiever
  class Validator
    include Exceptions
    TYPES = %w[accumulation slotted]
    VISIBILITIES = %w[hidden visible]

    def self.validate(filename)
      new(YAML.safe_load(File.read(filename))).validate
    end

    def initialize(config)
      @config = config
    end

    def check_type(type, thing)
      case type
      when Proc
        res = type.call(thing)
        unless res[0]
          raise(InvalidConfig::WrongType.new(thing, res[1]))
        end
      when Array
        unless type.include?(thing)
          raise(InvalidConfig::WrongType.new(thing, "one of #{type}"))
        end
      when Class
        unless thing.is_a?(type)
          raise(InvalidConfig::WrongType.new(thing, type))
        end
      end
    end

    def check_keys(allowed, required, hash, loc)
      required.each do |k|
        raise(InvalidConfig::MissingKey.new(k, loc)) unless hash.key?(k)
      end

      hash.keys.each do |k|
        raise(InvalidConfig::ExtraKey.new(k, loc)) unless allowed.keys.include?(k)
        check_type(allowed[k], hash[k])
      end
    end

    def check_root_keys
      check_keys(
        { 'achievements' => Hash, 'config' => Hash },
        %w[achievements],
        @config,
        'root'
      )
    end

    def check_badge(bdg, ach)
      allowed = {
        'img' => String,
        'required' => ->(v) {
          case v
          when Array, String
            if ach['type'] != 'slotted'
              raise(
                InvalidConfig::SlotError,
                "the type of #{ach['name']} is not slotted"
              )
            else
              v = v.is_a?(String) ? [v] : v
              v.each do |e|
                unless ach['slots'].include?(e)
                  raise(
                    InvalidConfig::SlotError,
                    "no such slot, #{e}, at achievement #{ach['name']}"
                  )
                end
              end
            end
            [true]
          when Integer
            [true]
          else
            [false, Integer]
          end
        }
      }
      required = %w[required]

      check_keys(allowed, required, bdg, "badge for #{ach['name']}")
    end

    def check_achievement(ach, name)
      allowed = {
        'badges' => Array,
        'visibility' => VISIBILITIES,
        'type' => TYPES,
        'slots' => Array,
        'desc' => ->(v) { [v.is_a?(Hash) || v.is_a?(String), "Hash or String"] }
      }
      required = %w[badges]
      required << 'slots' if ach['type'] == 'slotted'

      check_keys(allowed, required, ach, "achievment #{name}")

      ach['badges'].each do |bdg|
        raise(InvalidConfig::WrongType.new(bdg, Hash)) unless bdg.is_a?(Hash)
        check_badge(bdg, ach.merge("name" => name))
      end
    end

    def check_achievements
      @config['achievements'].each do |name, ach|
        raise(InvalidConfig::WrongType.new(ach, Hash)) unless ach.is_a?(Hash)
        check_achievement(ach, name)
      end
    end

    def validate
      check_root_keys
      check_achievements
    end
  end
end
