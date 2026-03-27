# frozen_string_literal: true

module RuboCop
  module Cop
    module OpenProject
      # Warns against using a `NotImplementedError` exception when a method
      # should be implemented by a subclass or including module. Ruby's
      # `NotImplementedError` is reserved for platform-specific missing
      # features (e.g., methods depending on `fsync` or `fork`), not for
      # abstract method patterns.
      #
      # @example
      #   # bad
      #   raise NotImplementedError
      #
      #   # bad
      #   raise NotImplementedError, "Subclasses must implement #foo"
      #
      #   # bad
      #   raise NotImplementedError.new("Subclasses must implement #foo")
      #
      #   # bad
      #   fail NotImplementedError
      #
      #   # good
      #   raise NotYetImplementedError
      #
      #   # good
      #   raise SubclassResponsibilityError, "#{self.class} must implement #foo"
      #
      class NoNotImplementedError < Base
        MSG = "Do not raise `NotImplementedError` to signal an unimplemented abstract method. " \
              "Ruby's `NotImplementedError` is reserved for platform-specific missing features. " \
              "Raise a descriptive custom error class instead."

        RESTRICT_ON_SEND = %i[raise fail].freeze

        def_node_matcher :raises_not_implemented_error?, <<~PATTERN
          {
            (send nil? {:raise :fail} (const nil? :NotImplementedError) ...)
            (send nil? {:raise :fail} (send (const nil? :NotImplementedError) :new ...) ...)
          }
        PATTERN

        def on_send(node)
          return unless raises_not_implemented_error?(node)

          add_offense(node)
        end
      end
    end
  end
end
