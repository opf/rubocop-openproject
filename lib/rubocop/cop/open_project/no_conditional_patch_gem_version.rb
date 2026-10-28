# frozen_string_literal: true

module RuboCop
  module Cop
    module OpenProject
      # Checks that `patch_gem_version` is not wrapped in a condition.
      #
      # `patch_gem_version` raises when the patched gem is newer than the version the
      # patch was written for, which makes the application fail to boot on CI after a
      # gem upgrade. A condition around the call (e.g. `defined?` on a constant of a
      # gem that is only required in production) skips that version check as well,
      # so an outdated patch goes unnoticed. Move the condition inside the block.
      #
      # @example
      #   # bad
      #   if defined?(SomeGem::Thing)
      #     OpenProject::Patches.patch_gem_version "some-gem", "1.2.3" do
      #       SomeGem::Thing.prepend Patch
      #     end
      #   end
      #
      #   # bad
      #   OpenProject::Patches.patch_gem_version("some-gem", "1.2.3") { apply } if Rails.env.local?
      #
      #   # good
      #   OpenProject::Patches.patch_gem_version "some-gem", "1.2.3" do
      #     SomeGem::Thing.prepend Patch if defined?(SomeGem::Thing)
      #   end
      #
      class NoConditionalPatchGemVersion < Base
        MSG = "`patch_gem_version` must run unconditionally so CI catches gem upgrades. " \
              "Move the condition inside the block."

        RESTRICT_ON_SEND = %i[patch_gem_version].freeze

        def on_send(node)
          return unless node.each_ancestor(:if, :case, :and, :or).any?

          add_offense(node)
        end
      end
    end
  end
end
