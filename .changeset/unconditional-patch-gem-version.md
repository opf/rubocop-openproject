---
"@openproject/rubocop-openproject": minor
---

Add `OpenProject/NoConditionalPatchGemVersion` cop to catch `patch_gem_version` calls wrapped in a
condition. The version check inside `patch_gem_version` is what makes the application fail to boot
on CI when a patched gem is upgraded. The OpenTelemetry grape patch was guarded by
`defined?(OpenTelemetry::Instrumentation::Grape::EventHandler)`, which is only defined when
OpenTelemetry is enabled, so CI skipped the check and the gem upgrade went unnoticed. Conditions
belong inside the block, around the patch itself.
