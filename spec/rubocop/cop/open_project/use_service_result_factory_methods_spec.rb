# frozen_string_literal: true

RSpec.describe RuboCop::Cop::OpenProject::UseServiceResultFactoryMethods, :config do
  let(:config) { RuboCop::Config.new }

  it "registers an offense for ServiceResult.new without any success: argument" do
    expect_offense(<<~RUBY)
      ServiceResult.new
                    ^^^ OpenProject/UseServiceResultFactoryMethods: Use ServiceResult.failure instead of ServiceResult.new.
      ServiceResult.new(errors: ['error'])
                    ^^^ OpenProject/UseServiceResultFactoryMethods: Use ServiceResult.failure instead of ServiceResult.new.
    RUBY

    expect_correction(<<~RUBY)
      ServiceResult.failure
      ServiceResult.failure(errors: ['error'])
    RUBY
  end

  it "allows ServiceResult.new(success: some_value) (no explicit true/false value)" do
    expect_no_offenses("ServiceResult.new(success: some_value)")
    expect_no_offenses('ServiceResult.new(foo: "bar", success: some_value, bar: "baz")')
  end

  it "allows ServiceResult.new(**kw) (no explicit true/false value)" do
    expect_no_offenses("ServiceResult.new(**kw)")
    expect_no_offenses('ServiceResult.new(foo: "bar", **kw)')
    expect_no_offenses('ServiceResult.new(**kw, foo: "bar")')
  end

  include_context "ruby 3.1" do
    it "allows ServiceResult.new(success:) (no explicit true/false value)" do
      expect_no_offenses("ServiceResult.new(success:)")
      expect_no_offenses('ServiceResult.new(foo: "bar", success:, bar: "baz")')
    end

    it "allows ServiceResult.new(...) (no explicit true/false value)" do
      expect_no_offenses(<<~RUBY)
        def call(...)
          ServiceResult.new(...)
        end
      RUBY
    end
  end

  it "registers an offense for ServiceResult.new(success: true) with no additional args" do
    expect_offense(<<~RUBY)
      ServiceResult.new(success: true)
                        ^^^^^^^^^^^^^ OpenProject/UseServiceResultFactoryMethods: Use ServiceResult.success(...) instead of ServiceResult.new(success: true, ...).
    RUBY

    expect_correction(<<~RUBY)
      ServiceResult.success
    RUBY
  end

  it "registers an offense for ServiceResult.new(success: true) with additional args" do
    expect_offense(<<~RUBY)
      ServiceResult.new(success: true,
                        ^^^^^^^^^^^^^ OpenProject/UseServiceResultFactoryMethods: Use ServiceResult.success(...) instead of ServiceResult.new(success: true, ...).
                        message: 'Great!')
      ServiceResult.new(message: 'Great!',
                        success: true)
                        ^^^^^^^^^^^^^ OpenProject/UseServiceResultFactoryMethods: Use ServiceResult.success(...) instead of ServiceResult.new(success: true, ...).
    RUBY

    expect_correction(<<~RUBY)
      ServiceResult.success(message: 'Great!')
      ServiceResult.success(message: 'Great!')
    RUBY
  end

  it "registers an offense for ServiceResult.new(success: false) with no additional args" do
    expect_offense(<<~RUBY)
      ServiceResult.new(success: false)
                        ^^^^^^^^^^^^^^ OpenProject/UseServiceResultFactoryMethods: Use ServiceResult.failure(...) instead of ServiceResult.new(success: false, ...).
      ServiceResult.new success: false
                        ^^^^^^^^^^^^^^ OpenProject/UseServiceResultFactoryMethods: Use ServiceResult.failure(...) instead of ServiceResult.new(success: false, ...).
    RUBY

    expect_correction(<<~RUBY)
      ServiceResult.failure
      ServiceResult.failure
    RUBY
  end

  it "registers an offense for ServiceResult.new(success: false) with additional args" do
    expect_offense(<<~RUBY)
      ServiceResult.new(success: false,
                        ^^^^^^^^^^^^^^ OpenProject/UseServiceResultFactoryMethods: Use ServiceResult.failure(...) instead of ServiceResult.new(success: false, ...).
                        errors: ['error'])
      ServiceResult.new(errors: ['error'],
                        success: false)
                        ^^^^^^^^^^^^^^ OpenProject/UseServiceResultFactoryMethods: Use ServiceResult.failure(...) instead of ServiceResult.new(success: false, ...).
    RUBY

    expect_correction(<<~RUBY)
      ServiceResult.failure(errors: ['error'])
      ServiceResult.failure(errors: ['error'])
    RUBY
  end

  it "registers an offense for ServiceResult.new(success: true/false) with splat kwargs" do
    expect_offense(<<~RUBY)
      ServiceResult.new(success: true, **kw)
                        ^^^^^^^^^^^^^ OpenProject/UseServiceResultFactoryMethods: Use ServiceResult.success(...) instead of ServiceResult.new(success: true, ...).
      ServiceResult.new(success: false, **kw)
                        ^^^^^^^^^^^^^^ OpenProject/UseServiceResultFactoryMethods: Use ServiceResult.failure(...) instead of ServiceResult.new(success: false, ...).
    RUBY

    expect_correction(<<~RUBY)
      ServiceResult.success(**kw)
      ServiceResult.failure(**kw)
    RUBY
  end
end
