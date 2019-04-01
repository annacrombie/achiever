require 'rails_helper'

RSpec.describe Achiever::Config do
  before(:all) do
    @tmp_cfg = '../configs/tmp'
    FileUtils.mkdir_p(Rails.root.join(@tmp_cfg))
  end

  context 'error checking' do
    before(:each) do
      file = File.join(@tmp_cfg, 'config_spec_0.yml')
      @file = Rails.root.join(file)

      File.write(
        @file,
        YAML.dump(deep_keys_to_s(
          config: {
            defaults: {
              achievement: { type: 'slotted' }
            }
          },
          achievements: {
            name: {
              badges: [{ required: 'a' }] } }
        ))
      )
      @config = Achiever::Config.new(file)
    end

    after(:each) { Achiever.config[:defaults][:achievement][:type] = 'cumulative' }

    it 'will ensure slotted achievements have slots' do
      expect { @config.achievements }.to raise_exception(TypeError)
        .with_message('name has a type of \'slotted\' but has no slots')
    end
  end

  context 'file modification' do
    before(:each) do
      file = File.join(@tmp_cfg, 'config_spec_1.yml')
      @file = Rails.root.join(file)

      File.write(
        @file,
        YAML.dump(deep_keys_to_s(
          achievements: {
            name: {
              type: 'slotted',
              slots: ['a', 'b'],
              badges: [{ required: 'a' }] } }
        ))
      )

      @config = Achiever::Config.new(file)
    end

    it 'will do nothing if the file hasnt changed' do
      expect(@config).to receive(:slot_values)

      @config.achievements

      expect(@config).not_to receive(:slot_values)

      @config.achievements
    end

    it 'can detect and update if the file is old' do
      @config.update_all_resources
      expect(@config.old_file?).to eq(false)

      data = @config.instance_variable_get(:@data)
      data[:achievements][:new] = { badges: [{ required: 2 }] }

      @mutex.synchronize do
        File.write(@file, YAML.dump(deep_keys_to_s(data)))

        expect(@config.old_file?).to eq(true)

        @config.instance_variable_set(:@mtime, Time.at(0))

        expect(@config.achievements).to have_key(:new)
      end
    end
  end

  context 'defaults' do
    it 'propogates defaults' do
      file = '../configs/default_spec.yml'

      @mutex.synchronize do
        Achiever.defaults[:achievement][:type] = 'slotted'
        config = Achiever::Config.new(file)

        expect(config.achievements[:name][:visibility]).to eq('hidden')
        expect(config.achievements[:name][:type]).to eq('slotted')
        expect(config.achievements[:name][:badges][0][:img]).to eq('lol')
      end
    end
  end
end
