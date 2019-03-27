module Achiever
  class Achievements
    include Kaicho

    def old_file?
      @mtime ||= Time.at(0)
      omtime = @mtime
      @mtime = File.mtime(Rails.root.join(Achiever.file))

      omtime < @mtime
    end

    def_resource(:data) do
      file = File.open(Rails.root.join(Achiever.file), 'r')
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
          achievement[:slots].each_with_index.map do |e, i|
            i + 1 if b[:required_slots].include?(e)
          end.compact.reduce(0) { |m, v| m + (2 ** v) }
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

        slot_values(achievement) if achievement[:type] == 'slotted'

        [name, achievement]
      end.to_h
    end
  end
end
