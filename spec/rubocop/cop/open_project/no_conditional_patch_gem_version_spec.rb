# frozen_string_literal: true

RSpec.describe RuboCop::Cop::OpenProject::NoConditionalPatchGemVersion, :config do
  let(:config) { RuboCop::Config.new }

  it "registers an offense when wrapped in an if block" do
    expect_offense(<<~RUBY)
      if defined?(SomeGem::Thing)
        OpenProject::Patches.patch_gem_version "some-gem", "1.2.3" do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/NoConditionalPatchGemVersion: #{described_class::MSG}
          SomeGem::Thing.prepend Patch
        end
      end
    RUBY
  end

  it "registers an offense when wrapped in an unless block" do
    expect_offense(<<~RUBY)
      unless Rails.env.production?
        OpenProject::Patches.patch_gem_version "some-gem", "1.2.3" do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/NoConditionalPatchGemVersion: #{described_class::MSG}
          SomeGem::Thing.prepend Patch
        end
      end
    RUBY
  end

  it "registers an offense when guarded by a modifier if" do
    expect_offense(<<~RUBY)
      OpenProject::Patches.patch_gem_version("some-gem", "1.2.3") { apply } if Rails.env.local?
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/NoConditionalPatchGemVersion: #{described_class::MSG}
    RUBY
  end

  it "registers an offense when guarded by a logical operator" do
    expect_offense(<<~RUBY)
      defined?(SomeGem::Thing) && OpenProject::Patches.patch_gem_version("some-gem", "1.2.3") { apply }
                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/NoConditionalPatchGemVersion: #{described_class::MSG}
    RUBY
  end

  it "registers an offense when the condition is further up the tree" do
    expect_offense(<<~RUBY)
      if defined?(SomeGem)
        Rails.application.config.to_prepare do
          OpenProject::Patches.patch_gem_version "some-gem", "1.2.3" do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/NoConditionalPatchGemVersion: #{described_class::MSG}
            SomeGem::Thing.prepend Patch
          end
        end
      end
    RUBY
  end

  it "does not register an offense for a top level call" do
    expect_no_offenses(<<~RUBY)
      OpenProject::Patches.patch_gem_version "some-gem", "1.2.3" do
        SomeGem::Thing.prepend Patch
      end
    RUBY
  end

  it "does not register an offense when called inside an unconditional block" do
    expect_no_offenses(<<~RUBY)
      initializer "some_engine.load_patches" do
        OpenProject::Patches.patch_gem_version("some-gem", "1.2.3") do
          SomeGem::Thing.prepend Patch
        end
      end
    RUBY
  end

  it "does not register an offense when the condition is inside the block" do
    expect_no_offenses(<<~RUBY)
      OpenProject::Patches.patch_gem_version "some-gem", "1.2.3" do
        SomeGem::Thing.prepend Patch if defined?(SomeGem::Thing)
      end
    RUBY
  end
end
