# frozen_string_literal: true

module RuboCop
  module Cop
    module OpenProject
      # Flags `data-test-selector` passed to a ViewComponent as a data
      # attribute instead of the `test_selector:` system argument.
      #
      # Primer only renders `test_selector:` outside production. Passing the
      # selector through `data:` bypasses that and ships the attribute to
      # production.
      #
      # The cop checks `.new` on constants under `ComponentNamespaces` or
      # listed in `AdditionalComponents`, slot calls (`with_*`), and the
      # methods listed in `ForwardingHelpers`. Inside those calls it also
      # checks hash arguments whose name ends in `_arguments`, except the
      # ones listed in `IgnoredNestedArguments`.
      #
      # Primer's form controls do not honour `test_selector:` and render it
      # as a literal attribute. They are skipped through `IgnoredComponents`
      # and `IgnoredSlots`.
      #
      # @example
      #   # bad
      #   Primer::Beta::Button.new(data: { test_selector: "save" })
      #
      #   # bad
      #   Primer::Beta::Button.new(data: { "test-selector": "save", turbo: true })
      #
      #   # bad
      #   menu.with_item(label: "Edit", content_arguments: { data: { test_selector: "edit" } })
      #
      #   # good
      #   Primer::Beta::Button.new(test_selector: "save")
      #
      #   # good
      #   Primer::Beta::Button.new(test_selector: "save", data: { turbo: true })
      #
      #   # good (not a component: no system argument available)
      #   link_to "Save", path, data: { test_selector: "save" }
      class TestSelectorSystemArgument < Base
        extend AutoCorrector

        MSG = "Pass `test_selector:` as a system argument instead of a `data-test-selector` " \
              "data attribute, so that it only renders outside production."

        DATA_KEYS = %w[test_selector test-selector].freeze
        FLAT_KEYS = %w[data-test-selector data_test_selector].freeze
        SLOT_PREFIX = "with_"
        NESTED_SUFFIX = "_arguments"

        def on_send(node)
          return unless component_call?(node)

          arguments = node.last_argument
          return unless arguments&.hash_type?

          check_arguments(arguments)
          nested_arguments(arguments).each { |nested| check_arguments(nested) }
        end
        alias on_csend on_send

        private

        def component_call?(node)
          name = node.method_name.to_s

          if node.method?(:new)
            component_constant?(node.receiver)
          elsif name.start_with?(SLOT_PREFIX)
            !config_list("IgnoredSlots").include?(name)
          else
            config_list("ForwardingHelpers").include?(name)
          end
        end

        def component_constant?(receiver)
          return false unless receiver&.const_type?

          name = receiver.const_name.delete_prefix("::")
          return false if config_list("IgnoredComponents").include?(name)

          config_list("AdditionalComponents").include?(name) ||
            config_list("ComponentNamespaces").any? { |namespace| name.start_with?("#{namespace}::") }
        end

        def nested_arguments(arguments)
          arguments.pairs.filter_map do |pair|
            name = key_name(pair)
            next unless name&.end_with?(NESTED_SUFFIX) && pair.value.hash_type?
            next if config_list("IgnoredNestedArguments").include?(name)

            pair.value
          end
        end

        def check_arguments(arguments)
          arguments.pairs.each do |pair|
            name = key_name(pair)

            if name == "data" && pair.value.hash_type?
              selector = pair.value.pairs.find { |data_pair| DATA_KEYS.include?(key_name(data_pair)) }
              register(arguments, pair, selector) if selector
            elsif FLAT_KEYS.include?(name)
              register(arguments, nil, pair)
            end
          end
        end

        def register(arguments, data_pair, selector)
          add_offense(selector) do |corrector|
            next if arguments.pairs.any? { |pair| key_name(pair) == "test_selector" }

            move_selector(corrector, data_pair, selector)
          end
        end

        def move_selector(corrector, data_pair, selector)
          replacement = "test_selector: #{selector.value.source}"

          if data_pair.nil? || data_pair.value.pairs.one?
            corrector.replace(data_pair || selector, replacement)
          else
            corrector.remove(range_with_separator(data_pair.value, selector))
            corrector.insert_before(data_pair, "#{replacement},#{separator_before(data_pair)}")
          end
        end

        def range_with_separator(hash, selector)
          pairs = hash.pairs
          index = pairs.index(selector)

          if index == pairs.size - 1
            selector.source_range.with(begin_pos: pairs[index - 1].source_range.end_pos)
          else
            selector.source_range.with(end_pos: pairs[index + 1].source_range.begin_pos)
          end
        end

        def separator_before(pair)
          range = pair.source_range
          indentation = range.source_line[0...range.column]

          indentation.strip.empty? ? "\n#{indentation}" : " "
        end

        def key_name(pair)
          key = pair.key
          key.value.to_s if key.sym_type? || key.str_type?
        end

        def config_list(key)
          cop_config.fetch(key, [])
        end
      end
    end
  end
end
