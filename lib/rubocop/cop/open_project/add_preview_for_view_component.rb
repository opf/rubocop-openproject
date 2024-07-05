# frozen_string_literal: true

module RuboCop
  module Cop
    module OpenProject
      # A lookbook preview must exist for each ViewComponent.
      #
      # Components are located in `app/components` and previews are searched in
      # `lookbook/previews`.
      class AddPreviewForViewComponent < Base
        COMPONENT_PATH = "/app/components/"
        PREVIEW_PATH = "/lookbook/previews/"

        def on_class(node)
          path = node.loc.expression.source_buffer.name
          return unless path.include?(COMPONENT_PATH) && path.end_with?(".rb")

          preview_path = path.sub(COMPONENT_PATH, PREVIEW_PATH).sub(".rb", "_preview.rb")

          return if File.exist?(preview_path)

          message = "Missing Lookbook preview for #{path}. Expected preview to exist at #{preview_path}."
          add_offense(node.loc.name, message:)
        end
      end
    end
  end
end
