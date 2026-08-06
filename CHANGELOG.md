# rubocop-openproject

## 0.7.1

### Patch Changes

- 2e41102: Widen `OpenProject/UseEffectiveTypeForConfiguration` to catch safe navigation and the derived
  pattern readers. The cop only defined `on_send`, so `represented.type&.attribute_groups` parsed
  as a `csend` and slipped through entirely — which is how the whole work package schema
  representer read its form configuration off the root while the cop was enabled. Both sides of
  the call are now matched as `send` or `csend`. `enabled_patterns` and
  `replacement_pattern_defined_for?` join `CONFIGURATION_METHODS`: both resolve through
  `patterns`, which a variant can own independently, so they are as variant-specific as the
  aspect readers already listed.

  Expect new offenses in consumers wherever a configuration aspect was read off `type` with `&.`.

## 0.7.0

### Minor Changes

- ad3ff98: Add `OpenProject/UseEffectiveTypeForConfiguration` cop to catch reading a type's
  configuration off `#type` instead of `#effective_type`. A work package stores the root of its
  type family while its project may resolve that family to a variant configured differently, so
  reading an aspect (form configuration, workflows, custom fields, defaults, export templates)
  off the stored type silently answers with the root's configuration. The failure is quiet — a
  project running the root behaves correctly, so a spec written without a variant passes while
  the feature is broken wherever a variant is resolved. Inherited core settings (`name`,
  `color`, `is_milestone`, `is_in_roadmap`) are read from the root by design and are not flagged.

## 0.6.0

### Minor Changes

- 6e7b812: Add `OpenProject/UseRenderModeInsteadOfPrimitives` cop to flag `format_text` calls that pass the external-rendering primitive flags (`static_html: true`, `plain_text: true`, `only_path: false`) instead of the canonical `render_mode:` API or the `format_mail_html` / `format_mail_text` mailer view helpers.

## [0.5.0] - 2026-05-05

- Add `OpenProject/NoParamsInWorkPackageWhereId` cop to catch
  `WorkPackage.where(id: params[...])` patterns that silently drop semantic
  identifiers (e.g. `"PROJ-42"`) when PostgreSQL casts the string to integer 0.

## [0.4.0] - 2026-03-27

- Add NoNotImplementedError cop

## [0.3.0] - 2025-07-11

- Remove redundant NoDoEndBlockWithRSpecCapybaraMatcherInExpect cop

## [0.2.0] - 2024-10-18

- Add `OpenProject/NoSleepInFeatureSpecs` cop to check that `sleep` calls in
  feature specs are not greater than 1 second.

## [0.1.0] - 2024-07-05

- Initial release
