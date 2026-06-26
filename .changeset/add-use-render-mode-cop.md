---
"@openproject/rubocop-openproject": minor
---

Add `OpenProject/UseRenderModeInsteadOfPrimitives` cop to flag `format_text` calls that pass the external-rendering primitive flags (`static_html: true`, `plain_text: true`, `only_path: false`) instead of the canonical `render_mode:` API or the `format_mail_html` / `format_mail_text` mailer view helpers.
