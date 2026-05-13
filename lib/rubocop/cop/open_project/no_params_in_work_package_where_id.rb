# frozen_string_literal: true

module RuboCop
  module Cop
    module OpenProject
      # Flags `WorkPackage.where(id: params[...])` patterns. With semantic work
      # package identifiers enabled, params may carry strings like "PROJ-42"
      # that PostgreSQL silently casts to integer 0 inside `where(id: ...)`,
      # producing an empty result set instead of an error. Use the dedicated
      # resolver `WorkPackage.where_display_id_in(...)` which partitions
      # numeric and semantic inputs and consults the alias table.
      #
      # The cop fires when the receiver chain demonstrably resolves to a
      # WorkPackage relation — either rooted at the `WorkPackage` constant or
      # passing through an association call whose name ends in
      # `work_packages` (e.g. `project.work_packages`,
      # `user.assigned_work_packages`) — and the value is derived from
      # `params[...]`. Internal subquery composition
      # (`where(id: scope.pluck(:id))`) and primary-key literals are left
      # alone.
      #
      # @example
      #   # bad
      #   WorkPackage.where(id: params[:work_package_id])
      #
      #   # bad
      #   WorkPackage.where(id: params[:work_package_id] || params[:ids])
      #
      #   # bad
      #   WorkPackage.includes(:project).where(id: params[:ids])
      #
      #   # bad
      #   project.work_packages.where(id: params[:work_package_id])
      #
      #   # bad
      #   current_user.assigned_work_packages.where(id: params[:ids])
      #
      #   # good
      #   WorkPackage.where_display_id_in(params[:work_package_id])
      #
      #   # good
      #   project.work_packages.where_display_id_in(params[:work_package_id])
      #
      #   # good (primary key, not user input)
      #   WorkPackage.where(id: 42)
      #
      #   # good (subquery, not user input)
      #   WorkPackage.where(id: other_scope.select(:id))
      class NoParamsInWorkPackageWhereId < Base
        extend AutoCorrector

        MSG = "Avoid `WorkPackage.where(id: params[...])` — semantic identifiers like " \
              '"PROJ-42" are silently coerced to 0 by the SQL cast. ' \
              "Use `WorkPackage.where_display_id_in(...)` instead."

        RESTRICT_ON_SEND = %i[where].freeze

        def_node_matcher :params_access?, <<~PATTERN
          (send (send nil? :params) :[] _)
        PATTERN

        # A receiver that traces back through any chain of sends to either:
        #   - the `WorkPackage` constant: `WorkPackage`, `WorkPackage.foo`, ...
        #   - an association call whose name ends in `work_packages`:
        #     `project.work_packages`, `user.assigned_work_packages`, ...
        # The recursion handles arbitrarily deep chains in either form.
        def_node_matcher :work_package_relation?, <<~PATTERN
          {
            (const nil? :WorkPackage)
            (send _ #work_package_association? ...)
            (send #work_package_relation? _ ...)
          }
        PATTERN

        def on_send(node)
          return unless work_package_relation?(node.receiver)

          hash_arg = node.first_argument
          id_value = id_value_from_hash(hash_arg)
          return unless id_value && value_uses_params?(id_value)

          add_offense(node) do |corrector|
            next unless autocorrectable_value?(id_value) && sole_id_predicate?(hash_arg)

            corrector.replace(node, "#{node.receiver.source}.where_display_id_in(#{id_value.source})")
          end
        end

        private

        def id_value_from_hash(arg)
          return unless arg&.hash_type?

          pair = arg.pairs.find { |p| p.key.sym_type? && p.key.value == :id }
          pair&.value
        end

        # Refuse to autocorrect when the hash carries additional predicates
        # (e.g. `where(id: params[:id], project_id: 5)`); rewriting to
        # `where_display_id_in(params[:id])` would silently drop them.
        def sole_id_predicate?(hash_arg)
          hash_arg.pairs.size == 1
        end

        def value_uses_params?(node)
          return true if params_access?(node)

          node.each_descendant(:send).any? { |descendant| params_access?(descendant) }
        end

        def autocorrectable_value?(node)
          return true if params_access?(node)
          return false unless node.or_type?

          node.children.all? { |child| autocorrectable_value?(child) }
        end

        def work_package_association?(method_name)
          method_name.to_s.end_with?("work_packages")
        end
      end
    end
  end
end
