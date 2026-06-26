# Releasing

Releases are driven by [changesets](https://github.com/changesets/changesets) and
GitHub Actions. No RubyGems credentials are needed on a maintainer's machine.

## How it works

1. **Every change ships with a changeset.** In your PR, run `npx changeset`, pick
   the bump level, and write a summary. This drops a markdown file in `.changeset/`
   that you commit alongside the change.
2. **On merge to `main`,** the [`Release`](workflows/release.yml) workflow runs
   `changesets/action`. If there are pending changesets, it opens (or updates) a
   **Release Tracking** pull request that:
   - bumps the version in `package.json`,
   - syncs it into `lib/rubocop/open_project/version.rb` via `script/version`,
   - consumes the changeset files and writes the new `CHANGELOG.md` section.
3. **Merge the Release Tracking PR.** The `Release` workflow then runs
   `script/changeset-publish`, which tags `vX.Y.Z` and creates a GitHub Release.
4. **Publishing the GitHub Release** triggers the
   [`Publish`](workflows/publish.yml) workflow, which builds the gem and runs
   `bundle exec rake release` to push it to
   [rubygems.org](https://rubygems.org).

Versioning and the changelog are fully automated; the only human steps are writing
changesets and merging the Release Tracking PR.

## One-time setup

These org-level secrets must be available to this repository:

- **`OPENRPOJECTCI_GH_TOKEN`** - the `openprojectci` GitHub token used to
  check out, open the Release Tracking PR, and push the tag. (A standard
  `GITHUB_TOKEN` is not used because PRs it opens do not trigger CI, and it
  cannot push to a protected `main`.)
- **`RUBYGEMS_TOKEN_SHARED`** - the shared RubyGems API key the `Publish`
  workflow writes to `~/.gem/credentials` to push the gem. The gem owner's
  account / key must have MFA enabled, since the gemspec sets
  `rubygems_mfa_required`.
