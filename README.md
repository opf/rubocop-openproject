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

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Releasing

1. Update the version in `lib/rubocop/open_project/version.rb`
2. Update the changelog in `CHANGELOG.md`
3. Run `bundle install` to update `Gemfile.lock`
4. Run `rake` to check everything is fine and fix any issues
5. Commit your changes (`git commit -am 'Prepare release X.Y.Z'`)
6. Run `bundle exec rake release`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/opf/rubocop-openproject.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
