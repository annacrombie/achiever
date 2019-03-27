require 'rails_helper'

RSpec.describe Achiever::ConfigValidator do
  [
    ['missing_achievements_key.yml'],
    ['extra_random_key.yml'],
    ['invalid_visibility.yml'],
    ['invalid_type.yml'],
    ['invalid_badge_slots_1.yml'],
    ['invalid_badge_slots_2.yml'],
  ].each do |c|
    context c do
      it 'should not be valid' do
        expect(Achiever::ConfigValidator.validate(load_yaml(c))).not_to be_valid
      end

      it 'raises an exception' do
        expect { Achiever::ConfigValidator.valid!(load_yaml(c)) }.to raise_exception(
          Achiever::Exceptions::InvalidConfig
        )
      end
    end
  end

  [
    ['missing_config_key.yml']
  ].each do |c|
    context c do
      it 'should be valid' do
        expect(Achiever::ConfigValidator.valid?(load_yaml(c))).to eq(true)
      end
    end
  end
end
