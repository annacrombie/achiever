module Achiever
  module Types
    module Base
      class<<self
        def not_implemented
          raise(NotImplementedError, 'please a specific type module')
        end
      end

      %i[overall_progress achieved? check_progress schedule achieve achieve_raw
      ].each do |m|
        define_method(m) { |*| Base.not_implemented }
      end
    end
  end
end
