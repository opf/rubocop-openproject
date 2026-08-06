# frozen_string_literal: true

RSpec.describe RuboCop::Cop::OpenProject::UseEffectiveTypeForConfiguration, :config do
  let(:config) { RuboCop::Config.new }

  context "when a configuration aspect is read off a type call" do
    it "registers an offense for attribute_groups" do
      expect_offense(<<~RUBY)
        work_package.type.attribute_groups
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/UseEffectiveTypeForConfiguration: #{described_class::MSG}
      RUBY
    end

    it "registers an offense for custom_fields" do
      expect_offense(<<~RUBY)
        work_package.type.custom_fields
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/UseEffectiveTypeForConfiguration: #{described_class::MSG}
      RUBY
    end

    it "registers an offense for a call with arguments" do
      expect_offense(<<~RUBY)
        work_package.type.statuses(include_default: true)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/UseEffectiveTypeForConfiguration: #{described_class::MSG}
      RUBY
    end

    it "registers an offense for a receiverless type call" do
      expect_offense(<<~RUBY)
        type.patterns
        ^^^^^^^^^^^^^ OpenProject/UseEffectiveTypeForConfiguration: #{described_class::MSG}
      RUBY
    end

    it "registers an offense through a longer receiver chain" do
      expect_offense(<<~RUBY)
        model.work_package.type.workflows
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/UseEffectiveTypeForConfiguration: #{described_class::MSG}
      RUBY
    end

    it "registers an offense for each configuration aspect" do
      described_class::CONFIGURATION_METHODS.each do |aspect|
        source = "work_package.type.#{aspect}"

        expect_offense(<<~RUBY)
          #{source}
          #{'^' * source.length} OpenProject/UseEffectiveTypeForConfiguration: #{described_class::MSG}
        RUBY
      end
    end
  end

  # Safe navigation reads the root exactly like a plain call does, and is the shape the mistake
  # took in the API schema representer, which the cop was live for and did not catch.
  context "when the read uses safe navigation" do
    it "registers an offense when the aspect is called with &." do
      expect_offense(<<~RUBY)
        represented.type&.attribute_groups
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/UseEffectiveTypeForConfiguration: #{described_class::MSG}
      RUBY
    end

    it "registers an offense when the type itself is reached with &." do
      expect_offense(<<~RUBY)
        model&.type.enabled_patterns
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/UseEffectiveTypeForConfiguration: #{described_class::MSG}
      RUBY
    end

    it "registers an offense when both sides use &." do
      expect_offense(<<~RUBY)
        model&.type&.replacement_pattern_defined_for?(:subject)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/UseEffectiveTypeForConfiguration: #{described_class::MSG}
      RUBY
    end

    it "registers no offense when effective_type is reached with &." do
      expect_no_offenses(<<~RUBY)
        model.effective_type&.enabled_patterns
      RUBY
    end
  end

  context "when the read already goes through effective_type" do
    it "registers no offense" do
      expect_no_offenses(<<~RUBY)
        work_package.effective_type.attribute_groups
      RUBY
    end

    it "registers no offense for the project-level resolution" do
      expect_no_offenses(<<~RUBY)
        project.effective_type(type).attribute_groups
      RUBY
    end
  end

  context "with an inherited core setting rather than a configuration aspect" do
    it "registers no offense for name" do
      expect_no_offenses(<<~RUBY)
        work_package.type.name
      RUBY
    end

    it "registers no offense for is_milestone?" do
      expect_no_offenses(<<~RUBY)
        work_package.type.is_milestone?
      RUBY
    end

    it "registers no offense for color" do
      expect_no_offenses(<<~RUBY)
        work_package.type.color
      RUBY
    end
  end

  context "when administration holds an explicit type" do
    it "registers no offense for an instance variable" do
      expect_no_offenses(<<~RUBY)
        @type.attribute_groups
      RUBY
    end

    it "registers no offense for a local variable" do
      expect_no_offenses(<<~RUBY)
        type = source_type
        type.attribute_groups
      RUBY
    end

    it "registers no offense for a block argument" do
      expect_no_offenses(<<~RUBY)
        types.each { |type| type.attribute_groups }
      RUBY
    end
  end

  context "with an unrelated receiver that happens to answer the same name" do
    it "registers no offense when the aspect is not read off a type" do
      expect_no_offenses(<<~RUBY)
        custom_field.attribute_groups
      RUBY
    end
  end
end
