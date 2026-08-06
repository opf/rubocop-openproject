# frozen_string_literal: true

module RuboCop
  module Cop
    module OpenProject
      # Flags reading a type's configuration off `#type` rather than `#effective_type`.
      #
      # A work package stores the root of its type family, while the project it lives in may
      # resolve that family to a variant configured differently — a different form
      # configuration, workflow, set of custom fields, defaults or export templates. Reading a
      # configuration aspect off the stored type therefore answers with the root's
      # configuration and silently ignores the variant.
      #
      # The failure mode is quiet: a project running the root behaves correctly, so a spec
      # written without a variant passes while the feature is broken for every project that
      # resolves one. That is what this cop is here to catch.
      #
      # Only configuration aspects are flagged. `name`, `color`, `is_milestone` and
      # `is_in_roadmap` are inherited from the root by design, so reading those off `#type` is
      # correct and left alone.
      #
      # Deliberately narrow: it fires when the receiver is literally a `type` call, which is
      # the shape the mistake takes in practice. Administration code holding an explicit type
      # (`@type.attribute_groups`) is reading that member's own configuration on purpose and is
      # not flagged, and neither is a type held in a local variable.
      #
      # @example
      #   # bad
      #   work_package.type.attribute_groups
      #
      #   # bad
      #   work_package.type.custom_fields
      #
      #   # bad — inside WorkPackage itself
      #   type.statuses(include_default: true)
      #
      #   # bad — safe navigation on either side reads the root just the same
      #   represented.type&.attribute_groups
      #   model&.type.enabled_patterns
      #
      #   # good
      #   work_package.effective_type.attribute_groups
      #
      #   # good — when there is no work package to ask
      #   project.effective_type(type).attribute_groups
      #
      #   # good — inherited from the root by design
      #   work_package.type.name
      #   work_package.type.is_milestone?
      #
      #   # good — administration reads a specific member's own configuration
      #   @type.attribute_groups
      class UseEffectiveTypeForConfiguration < Base
        MSG = "Read configuration through `effective_type`, not `type` — the stored type is " \
              "the family's root, so this ignores the variant the project resolves to."

        # Configuration aspects, per Type::ConfigurationLink::ASPECTS and the readers
        # Type::ConfigurationLinkable resolves through the link chain, plus the derived readers
        # that sit on top of one — `enabled_patterns` and `replacement_pattern_defined_for?`
        # both resolve through `patterns` and are just as variant-specific.
        CONFIGURATION_METHODS = %i[
          artefact_export_enabled?
          artefact_export_mode
          attribute_groups
          custom_field_ids
          custom_fields
          description
          enabled_patterns
          export_templates_disabled
          export_templates_order
          patterns
          project_custom_field_type_mappings
          replacement_pattern_defined_for?
          statuses
          workflows
        ].freeze

        RESTRICT_ON_SEND = CONFIGURATION_METHODS

        # Both node types on both sides: `type&.attribute_groups` reads the root exactly like
        # `type.attribute_groups` does, and the mistake is written with `&.` at least as often.
        def_node_matcher :type_call?, <<~PATTERN
          ({send csend} _ :type)
        PATTERN

        def on_send(node)
          return unless type_call?(node.receiver)

          add_offense(node)
        end
        alias on_csend on_send
      end
    end
  end
end
