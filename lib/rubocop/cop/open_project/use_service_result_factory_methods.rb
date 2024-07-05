# frozen_string_literal: true

module RuboCop
  module Cop
    module OpenProject
      # Favor usage of ServiceResult factory methods instead of using
      # `success: true/false` in constructor.
      #
      # @example
      #   # bad
      #   ServiceResult.new(success: true, result: 'result')
      #
      #   # bad
      #   ServiceResult.new(success: false, errors: ['error'])
      #
      #   # good
      #   ServiceResult.success(result: 'result')
      #
      #   # good
      #   ServiceResult.failure(errors: ['error'])
      #
      #   # good
      #   ServiceResult.new(success: some_value)
      #
      #   # good
      #   ServiceResult.new(**kwargs)
      class UseServiceResultFactoryMethods < Base
        extend RuboCop::Cop::AutoCorrector

        MSG = "Use ServiceResult.%<factory_method>s(...) instead of ServiceResult.new(success: %<success_value>s, ...)."
        MSG_IMPLICIT_FAILURE = "Use ServiceResult.failure instead of ServiceResult.new."

        # TODO: Don't call `on_send` unless the method name is in this list
        # If you don't need `on_send` in the cop you created, remove it.
        RESTRICT_ON_SEND = %i[new].freeze

        def_node_matcher :service_result_constructor?, <<~PATTERN
          (send
            $(const nil? :ServiceResult) :new
            ...
          )
        PATTERN

        def_node_matcher :constructor_with_explicit_success_arg, <<~PATTERN
          (send
            (const nil? :ServiceResult) :new
            (hash
              <
                $(pair (sym :success) ({true | false}))
                ...
              >
            )
          )
        PATTERN

        def on_send(node)
          return unless service_result_constructor?(node)

          if success_argument_present?(node)
            add_offense_if_explicit_success_argument(node)
          elsif success_argument_possibly_present?(node)
            return # rubocop:disable Style/RedundantReturn
          else
            add_offense_for_implicit_failure(node)
          end
        end

        private

        def success_argument_present?(node)
          hash_argument = node.arguments.find(&:hash_type?)
          return false unless hash_argument

          hash_argument.keys.any? { |key| key.sym_type? && key.value == :success }
        end

        def success_argument_possibly_present?(node)
          return true if node.arguments.find(&:forwarded_args_type?)

          hash_argument = node.arguments.find(&:hash_type?)
          return false unless hash_argument

          hash_argument.children.any?(&:kwsplat_type?)
        end

        def add_offense_if_explicit_success_argument(node)
          constructor_with_explicit_success_arg(node) do |success_argument|
            message = format(MSG, success_value: success_value(success_argument),
                                  factory_method: factory_method(success_argument))
            add_offense(success_argument, message:) do |corrector|
              corrector.replace(node.loc.selector, factory_method(success_argument))
              corrector.remove(removal_range(node, success_argument))
            end
          end
        end

        def add_offense_for_implicit_failure(node)
          add_offense(node.loc.selector, message: MSG_IMPLICIT_FAILURE) do |corrector|
            corrector.replace(node.loc.selector, "failure")
          end
        end

        def success_value(success_argument)
          success_argument.value.source
        end

        def factory_method(success_argument)
          success_argument.value.source == "true" ? "success" : "failure"
        end

        def removal_range(node, success_argument)
          if sole_argument?(success_argument)
            all_parameters_range(node)
          else
            success_parameter_range(success_argument)
          end
        end

        def sole_argument?(arg)
          arg.parent.loc.expression == arg.loc.expression
        end

        def all_parameters_range(node)
          node.loc.selector.end.join(node.loc.expression.end)
        end

        # rubocop:disable Metrics/AbcSize
        def success_parameter_range(success_argument)
          if success_argument.left_sibling
            success_argument.left_sibling.loc.expression.end.join(success_argument.loc.expression.end)
          else
            success_argument.loc.expression.begin.join(success_argument.right_sibling.loc.expression.begin)
          end
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end
