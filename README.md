# rubocop-openproject

This is a collection of the cops written to be used in the
[OpenProject repository](https://github.com/opf/openproject).

## Installation

Add this gem to the `Gemfile`:

```ruby
gem "rubocop-openproject", require: false
```

Run `bundle install`.

Finally in the `.rubocop.yml` file, add the following:

```
require:
  - rubocop-openproject
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

When working on a change, add a changeset describing it: run `npx changeset`
(or `./node_modules/.bin/changeset` after `npm install`), pick the bump
(`patch` / `minor` / `major`), and write a short summary. This adds a file under
`.changeset/`; commit it with your PR. The release automation turns accumulated
changesets into the next version bump and `CHANGELOG.md` entry.

## Releasing

Releases are driven by [changesets](https://github.com/changesets/changesets) and
GitHub Actions, so no RubyGems credentials are needed on your machine. See
[.github/RELEASING.md](.github/RELEASING.md) for the flow and one-time setup.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/opf/rubocop-openproject.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
