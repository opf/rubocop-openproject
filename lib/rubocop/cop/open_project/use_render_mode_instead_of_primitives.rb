# frozen_string_literal: true

module RuboCop
  module Cop
    module OpenProject
      # Flags `format_text` calls that pass the external-rendering primitive
      # flags (`static_html: true`, `plain_text: true`, `only_path: false`)
      # instead of the canonical `render_mode:` API.
      #
      # `format_text` renders trusted Markdown for two distinct audiences:
      # in-app HTML (the default) and external surfaces such as mailer
      # bodies or feeds. The external surface needs absolute URLs and a
      # subset of macros pre-resolved to static HTML / plain text, because
      # the recipient has no JavaScript runtime to hydrate the rest. The
      # primitive flags express that requirement as three loosely coupled
      # toggles, which makes call sites easy to get partially right (and
      # silently wrong — see openproject#74762, where a mailer view skipped
      # `static_html: true` and rendered numeric work package IDs instead of
      # their semantic identifiers).
      #
      # The canonical API is `render_mode: :external_html` /
      # `render_mode: :external_text`, with the mailer view helpers
      # `format_mail_html` and `format_mail_text` as the preferred form
      # inside mailer templates. The cop fires on both `.rb` and `.erb`
      # sources via OpenProject's erb_lint Rubocop bridge.
      #
      # @example
      #   # bad
      #   format_text("hi", static_html: true, only_path: false)
      #
      #   # bad
      #   format_text("hi", plain_text: true, only_path: false)
      #
      #   # bad
      #   format_text("hi", only_path: false)
      #
      #   # bad (two-arg form)
      #   format_text(@user, :name, only_path: false)
      #
      #   # good (canonical API)
      #   format_text("hi", render_mode: :external_html)
      #
      #   # good (mailer view helper)
      #   format_mail_html("hi")
      #
      #   # good (in-app default; no external flags)
      #   format_text("hi", only_path: true)
      #
      #   # good (render_mode present — primitive override is an explicit escape hatch)
      #   format_text("hi", render_mode: :external_html, only_path: false)
      class UseRenderModeInsteadOfPrimitives < Base
        MSG_HTML = "Use `render_mode: :external_html` (or `format_mail_html` in mailer views) " \
                   "instead of the primitive flags `static_html: true` / `only_path: false`. " \
                   "The `render_mode:` API documents intent and bundles the coupled toggles " \
                   "that silently produced numeric IDs in watcher notifications (openproject#74762)."

        MSG_TEXT = "Use `render_mode: :external_text` (or `format_mail_text` in mailer views) " \
                   "instead of the primitive flags `plain_text: true` / `only_path: false`. " \
                   "The `render_mode:` API documents intent and bundles the coupled toggles " \
                   "that silently produced numeric IDs in watcher notifications (openproject#74762)."

        MSG_ONLY_PATH = "Use `render_mode: :external_html` (or `format_mail_html` in mailer views) " \
                        "instead of passing `only_path: false` on its own. The bare flag is " \
                        "an under-specified external render that silently produced numeric IDs " \
                        "in watcher notifications (openproject#74762)."

        RESTRICT_ON_SEND = %i[format_text].freeze

        def on_send(node)
          hash_arg = node.last_argument
          return unless hash_arg&.hash_type?

          pairs = symbol_keyed_pairs(hash_arg)
          return if render_mode_present?(pairs)

          static_html = pair_with_value(pairs, :static_html, true)
          plain_text  = pair_with_value(pairs, :plain_text, true)
          only_path_false = pair_with_value(pairs, :only_path, false)

          return unless static_html || plain_text || only_path_false

          add_offense(node, message: message_for(static_html, plain_text, only_path_false))
        end

        private

        def symbol_keyed_pairs(hash_arg)
          hash_arg.pairs.select { |p| p.key.sym_type? }
        end

        def render_mode_present?(pairs)
          pairs.any? { |p| p.key.value == :render_mode }
        end

        def pair_with_value(pairs, key, value)
          pairs.find { |p| p.key.value == key && literal_equals?(p.value, value) }
        end

        def literal_equals?(node, value)
          case value
          when true then node.true_type?
          when false then node.false_type?
          end
        end

        def message_for(static_html, plain_text, only_path_false)
          return MSG_HTML if static_html
          return MSG_TEXT if plain_text

          MSG_ONLY_PATH if only_path_false
        end
      end
    end
  end
end
