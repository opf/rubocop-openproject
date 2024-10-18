# frozen_string_literal: true

RSpec.describe RuboCop::Cop::OpenProject::NoSleepInFeatureSpecs, :config do
  let(:config) { RuboCop::Config.new }

  it "registers an offense for sleeping more than 1 second in a feature spec" do
    expect_offense(<<~RUBY, "spec/features/some_spec.rb")
      sleep 1.5
      ^^^^^^^^^ OpenProject/NoSleepInFeatureSpecs: #{described_class::MSG}
      sleep 20
      ^^^^^^^^ OpenProject/NoSleepInFeatureSpecs: #{described_class::MSG}
      sleep
      ^^^^^ OpenProject/NoSleepInFeatureSpecs: #{described_class::MSG}
    RUBY

    expect_no_corrections
  end

  it "does not register an offense in non-feature specs" do
    expect_no_offenses(<<~RUBY, "spec/some_spec.rb")
      sleep 1.5
    RUBY
  end

  it "registers an offense sleep is called with a non-numeric argument" do
    expect_offense(<<~RUBY, "spec/features/some_spec.rb")
      delay = 15
      sleep delay
      ^^^^^^^^^^^ OpenProject/NoSleepInFeatureSpecs: #{described_class::MSG}
    RUBY

    expect_no_corrections
  end
end
