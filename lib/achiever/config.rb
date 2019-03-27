module Achiever
  class Config
    include Kaicho

    def initialize(file)
      @file = Rails.root.join(file)
      super()
    end

    def old_file?
      @mtime ||= Time.at(0)
      omtime = @mtime
      @mtime = File.mtime(@file)

      omtime < @mtime
    end

    def_resource(:data) do
      file = File.open(@file, 'r')
      data = Util.deep_keys_to_sym(YAML.safe_load(file.read))
      ConfigValidator.valid!(data)
      data
    end

    def_resource(:cfg, accessors: :none, depends: { data: :keep }) do
      if data.key?(:config) && data[:config].key?(:defaults)
        %i[achievement badge].each do |d|
          if data[:config][:defaults].key?(d)
            Achiever.config[:defaults][d].merge!(
              data[:config][:defaults][d]
            )
          end
        end
      end
    end

    def slot_values(achievement)
      achievement[:slots].map!(&:to_sym)

      achievement[:badges].each do |b|
        b[:required_slots] =
          (b[:required].is_a?(Array) ? b[:required] : [b[:required]])
            .map(&:to_sym)

        b[:required] =
          Logic.slots_to_required(achievement[:slots], b[:required_slots])
      end
    end

    def_resource(:achievements, depends: { data: instance_method(:old_file?) }) do
      data[:achievements].map do |name, ach|
        achievement =
          Achiever.defaults[:achievement].merge(
            ach.merge(
              badges: ach[:badges].map do |bdg|
                Achiever.defaults[:badge].merge(bdg)
              end
            )
          )

        if achievement[:type] == 'slotted'
          unless achievement.key?(:slots)
            raise(TypeError, "#{name} has a type of 'slotted' but has no slots")
          end

          slot_values(achievement)
        end

        [name, achievement]
      end.to_h
    end
  end
end