---
"@openproject/rubocop-openproject": minor
---

Add `OpenProject/UseEffectiveTypeForConfiguration` cop to catch reading a type's
configuration off `#type` instead of `#effective_type`. A work package stores the root of its
type family while its project may resolve that family to a variant configured differently, so
reading an aspect (form configuration, workflows, custom fields, defaults, export templates)
off the stored type silently answers with the root's configuration. The failure is quiet — a
project running the root behaves correctly, so a spec written without a variant passes while
the feature is broken wherever a variant is resolved. Inherited core settings (`name`,
`color`, `is_milestone`, `is_in_roadmap`) are read from the root by design and are not flagged.
