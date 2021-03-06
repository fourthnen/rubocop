# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks the args passed to `fail` and `raise`.
      class RaiseArgs < Cop
        def on_send(node)
          return unless command?(:raise, node) || command?(:fail, node)

          case style
          when :compact
            check_compact(node)
          when :exploded
            check_exploded(node)
          end
        end

        private

        def check_compact(node)
          _receiver, selector, *args = *node

          return unless args.size > 1

          convention(node, :expression, message(selector))
        end

        def check_exploded(node)
          _receiver, selector, *args = *node

          return unless args.size == 1

          arg, = *args

          if arg.type == :send && arg.loc.selector.is?('new')
            convention(node, :expression, message(selector))
          end
        end

        def style
          case cop_config['EnforcedStyle']
          when 'compact' then :compact
          when 'exploded' then :exploded
          else fail 'Unknown style selected!'
          end
        end

        def message(method)
          case style
          when :compact
            "Provide an exception object as an argument to #{method}."
          when :exploded
            "Provide an exception class and message as arguments to #{method}."
          end
        end
      end
    end
  end
end
