module Achiever
  class Achievements
    include(Settei.cfg(
      file: 'config/achievements.yml',
      defaults: {
        badge: { img: '' },
        achievement: {
          type: 'accumulation',
          visibility: 'visible'
        }
      }
    ) { |s| s.private += %i[data mtime] })

    include Kaicho

    def old_file?
      @mtime ||= Time.at(0)
      omtime = @mtime
      @mtime = File.mtime(Rails.root.join(Achievements.file))

      omtime < @mtime
    end

    def_resource(:data) do
      file = File.open(Rails.root.join(Achievements.file), 'r')
      data = YAML.safe_load(file.read)

      ConfigValidator.valid!(data)

      data
    end

    def_resource(:cfg, accessors: :none, depends: { data: :keep }) do
      if data.key?('config') && data['config'].key?('defaults')
        %w[achievement badge].each do |d|
          if data['config']['defaults'].key?(d)
            Achievements.config[:defaults][d.to_sym].merge!(
              data['config']['defaults'][d].transform_keys(&:to_sym)
            )
          end
        end
      end
    end

    def_resource(:achievements, depends: { data: instance_method(:old_file?) }) do
      data['achievements'].map do |name, ach|
        [
          name.to_sym,
          Achievements.achievement_defaults.merge(
            badges: ach['badges'].map do |bdg|
              Achievements.badge_defaults.merge(bdg.transform_keys(&:to_sym))
            end
          ).merge(
            ach.reject { |k, _| k == 'badges' }.transform_keys(&:to_sym)
          ).yield_self do |s|
            if s[:type] == 'slotted'
              s[:slots].map!(&:to_sym)
              s[:badges].each do |b|
                b[:required_slots] = b[:required].is_a?(Array) ? b[:required].map(&:to_sym)
                                                               : [b[:required].to_sym]
                b[:required] =
                  s[:slots].each_with_index.map do |e, i|
                    i + 1 if b[:required_slots].include?(e)
                  end.compact.reduce(0) { |m, v| m + (2 ** v) }
              end
            end

            s
          end
        ]
      end.to_h
    end
  end
end
