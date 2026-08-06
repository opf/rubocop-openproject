---
"@openproject/rubocop-openproject": patch
---

Widen `OpenProject/UseEffectiveTypeForConfiguration` to catch safe navigation and the derived
pattern readers. The cop only defined `on_send`, so `represented.type&.attribute_groups` parsed
as a `csend` and slipped through entirely — which is how the whole work package schema
representer read its form configuration off the root while the cop was enabled. Both sides of
the call are now matched as `send` or `csend`. `enabled_patterns` and
`replacement_pattern_defined_for?` join `CONFIGURATION_METHODS`: both resolve through
`patterns`, which a variant can own independently, so they are as variant-specific as the
aspect readers already listed.

Expect new offenses in consumers wherever a configuration aspect was read off `type` with `&.`.
