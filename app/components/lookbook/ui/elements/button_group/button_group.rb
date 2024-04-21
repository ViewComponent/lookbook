module Lookbook
  module UI
    class ButtonGroup < BaseComponent
      with_slot :button do |*args, **kwargs, &block|
        if args.any? || kwargs.any?
          lb_button(*args, size: @size, **kwargs)
        else
          block.call
        end
      end

      attr_reader :size

      def initialize(size: :md, **kwargs)
        @size = size
      end
    end
  end
end
