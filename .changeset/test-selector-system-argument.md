---
"@openproject/rubocop-openproject": minor
---

Add `OpenProject/TestSelectorSystemArgument` cop. It flags `data-test-selector` passed to a
ViewComponent through `data:` (or as a flat `"data-test-selector":` keyword) instead of the
`test_selector:` system argument, which Primer only renders outside production. The cop checks
`.new` on constants under `ComponentNamespaces` (default `Primer`, `OpPrimer`) or listed in
`AdditionalComponents`, `with_*` slot calls, and methods listed in `ForwardingHelpers`,
including hash arguments named `*_arguments` except those in `IgnoredNestedArguments`.
Primer form controls render `test_selector:` as a literal attribute, so they are skipped through
`IgnoredComponents` and `IgnoredSlots`. Autocorrects by moving the key out of `data:`.

Expect new offenses in consumers wherever a component receives `data: { test_selector: }`.
