require 'rails_helper'

RSpec.describe Achiever::Validator do
  [
    ['missing_achievements_key.yml', :MissingKey],
    ['extra_random_key.yml', :ExtraKey],
    ['invalid_visibility.yml', :WrongType],
    ['invalid_type.yml', :WrongType],
    ['invalid_badge_slots_1.yml', :SlotError],
    ['invalid_badge_slots_2.yml', :SlotError],
  ].each do |c, e|
    context c do
      it "should raise #{e}" do
        expect { Achiever::Validator.validate(cf(c)) }.to raise_exception(cwe(e))
      end
    end
  end

  [
    ['missing_config_key.yml', :MissingKey]
  ].each do |c, e|
    context c do
      it "should not raise #{e}" do
        expect { Achiever::Validator.validate(cf(c)) }.not_to raise_exception
      end
    end
  end
end
