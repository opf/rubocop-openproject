# frozen_string_literal: true

module RuboCop
  module Cop
    module OpenProject
      # As +do .. end+ block has less precedence than method call, a +do .. end+
      # block at the end of a rspec matcher will be an argument to the +to+ method,
      # which is not handled by Capybara matchers (teamcapybara/capybara/#2616).
      #
      # @example
      #
      #   # bad
      #   expect(page).to have_selector("input") do |input|
      #     input.value == "hello world"
      #   end
      #
      #   # good
      #   expect(page).to have_selector("input") { |input| input.value == "hello world" }
      #
      #   # good
      #   expect(page).to have_selector("input", value: "hello world")
      #
      #   # good
      #   match_input_with_hello_world = have_selector("input") do |input|
      #     input.value == "hello world"
      #   end
      #   expect(page).to match_input_with_hello_world
      #
      #   # good
      #   expect(foo).to have_received(:bar) do |arg|
      #     arg == :baz
      #   end
      #
      class NoDoEndBlockWithRSpecCapybaraMatcherInExpect < Base
        # extend AutoCorrector

        CAPYBARA_MATCHER_METHODS = %w[selector css xpath text title current_path link button
                                      field checked_field unchecked_field select table
                                      sibling ancestor].flat_map do |matcher_type|
                                        ["have_#{matcher_type}", "have_no_#{matcher_type}"]
                                      end

        MSG = "The `do .. end` block is associated with `to` and not with Capybara matcher `%<matcher_method>s`."

        def_node_matcher :expect_to_with_block?, <<~PATTERN
          # ruby-parse output
          (block
            (send
              (send nil? :expect ...)
              :to
              ...
            )
            ...
          )
        PATTERN

        def_node_matcher :rspec_matcher, <<~PATTERN
          (send
            (send nil? :expect...)
            :to
            (:send nil? $_matcher_method ...)
          )
        PATTERN

        def on_block(node)
          return unless expect_to_with_block?(node)
          return unless capybara_matcher?(node)

          add_offense(offense_range(node), message: offense_message(node))
        end

        private

        def capybara_matcher?(node)
          matcher_name = node.send_node.arguments.first.method_name.to_s
          CAPYBARA_MATCHER_METHODS.include?(matcher_name)
        end

        def offense_range(node)
          node.send_node.loc.selector.join(node.loc.end)
        end

        def offense_message(node)
          rspec_matcher(node.send_node) do |matcher_method|
            format(MSG, matcher_method:)
          end
        end
      end
    end
  end
end
