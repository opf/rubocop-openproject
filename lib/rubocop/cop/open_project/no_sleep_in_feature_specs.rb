# frozen_string_literal: true

module RuboCop
  module Cop
    module OpenProject
      # Checks that feature specs do not use `sleep` greater than 1 second.
      #
      # Relying on `sleep` for synchronization reduces overall performance of
      # the test suite. Consider using Capybara `have_*` matchers or
      # rspec-wait `wait_for` method instead.
      #
      # @example
      #
      #   # bad
      #   sleep 20
      #
      #   # bad
      #   sleep 1.5
      #
      #   # bad
      #   delay = 15
      #   sleep delay
      #
      #   # good (use sparingly)
      #   sleep 1
      #
      #   # good
      #   expect(page).not_to have_text("please wait")
      #
      #   # good
      #   expect(page).to have_text("success")
      #
      #   good
      #   wait_for { work_package.reload.subject }.to eq("Updated name")
      class NoSleepInFeatureSpecs < Base
        MSG = "Avoid using `sleep` greater than 1 second in feature specs. " \
              "It will reduce overall performance of the test suite. " \
              "Consider using Capybara `have_*` matchers or rspec-wait " \
              "`wait_for` method instead."

        def_node_matcher :on_sleep_call, "(send nil? :sleep $...)"

        def on_send(node)
          return unless feature_spec?(processed_source)

          on_sleep_call(node) do |args|
            add_offense(node, message: MSG) if sleeping_too_much?(args[0])
          end
        end

        private

        def sleeping_too_much?(arg)
          return false if arg&.numeric_type? && arg.value.between?(0, 1)

          true
        end

        def feature_spec?(source)
          source.file_path.include?("_spec.rb") && source.file_path.include?("features/")
        end
      end
    end
  end
end
