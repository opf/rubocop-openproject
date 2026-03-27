# frozen_string_literal: true

RSpec.describe RuboCop::Cop::OpenProject::NoNotImplementedError, :config do
  let(:config) { RuboCop::Config.new }

  it "registers an offense when raising NotImplementedError" do
    expect_offense(<<~RUBY)
      raise NotImplementedError
      ^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/NoNotImplementedError: #{described_class::MSG}
    RUBY

    expect_no_corrections
  end

  it "registers an offense when raising NotImplementedError with a message argument" do
    expect_offense(<<~RUBY)
      raise NotImplementedError, "Subclasses must implement #foo"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/NoNotImplementedError: #{described_class::MSG}
    RUBY

    expect_no_corrections
  end

  it "registers an offense when raising NotImplementedError.new" do
    expect_offense(<<~RUBY)
      raise NotImplementedError.new("Subclasses must implement #foo")
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/NoNotImplementedError: #{described_class::MSG}
    RUBY

    expect_no_corrections
  end

  it "registers an offense when using the fail alias" do
    expect_offense(<<~RUBY)
      fail NotImplementedError
      ^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/NoNotImplementedError: #{described_class::MSG}
    RUBY

    expect_no_corrections
  end

  it "does not register an offense for other error classes" do
    expect_no_offenses(<<~RUBY)
      raise ArgumentError, "invalid argument"
    RUBY
  end

  it "does not register an offense for a namespaced constant named NotImplementedError" do
    expect_no_offenses(<<~RUBY)
      raise MyModule::NotImplementedError
    RUBY
  end
end
