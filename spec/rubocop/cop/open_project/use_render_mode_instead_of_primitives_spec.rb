# frozen_string_literal: true

RSpec.describe RuboCop::Cop::OpenProject::UseRenderModeInsteadOfPrimitives, :config do
  let(:config) { RuboCop::Config.new }

  context "with `static_html: true, only_path: false`" do
    it "registers an offense pointing to :external_html" do
      expect_offense(<<~RUBY)
        format_text("hi", static_html: true, only_path: false)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/UseRenderModeInsteadOfPrimitives: #{described_class::MSG_HTML}
      RUBY

      expect_no_corrections
    end
  end

  context "with `plain_text: true, only_path: false`" do
    it "registers an offense pointing to :external_text" do
      expect_offense(<<~RUBY)
        format_text("hi", plain_text: true, only_path: false)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/UseRenderModeInsteadOfPrimitives: #{described_class::MSG_TEXT}
      RUBY
    end
  end

  context "with `only_path: false` on its own" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        format_text("hi", only_path: false)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/UseRenderModeInsteadOfPrimitives: #{described_class::MSG_ONLY_PATH}
      RUBY
    end
  end

  context "with the two-arg form and `only_path: false`" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        format_text(@user, :name, only_path: false)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/UseRenderModeInsteadOfPrimitives: #{described_class::MSG_ONLY_PATH}
      RUBY
    end
  end

  context "with `static_html: true` alongside `render_mode:`" do
    it "does not register an offense (explicit escape hatch)" do
      expect_no_offenses(<<~RUBY)
        format_text("hi", render_mode: :external_html, static_html: true, only_path: false)
      RUBY
    end
  end

  context "with `only_path: true`" do
    it "does not register an offense (in-app default)" do
      expect_no_offenses(<<~RUBY)
        format_text("hi", only_path: true)
      RUBY
    end
  end

  context "with `static_html: false`" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        format_text("hi", static_html: false)
      RUBY
    end
  end

  context "with `plain_text: false`" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        format_text("hi", plain_text: false)
      RUBY
    end
  end

  context "with no kwargs" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        format_text(wp, :description)
      RUBY
    end
  end

  context "with unrelated kwargs only" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        format_text("hi", object: @message, format: :rich)
      RUBY
    end
  end

  context "when the method is not format_text" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        some_other_helper("hi", static_html: true, only_path: false)
      RUBY
    end
  end

  context "with `render_mode:` set to anything" do
    it "does not register an offense even when primitives are present" do
      expect_no_offenses(<<~RUBY)
        format_text("hi", render_mode: :in_app_html, only_path: false)
      RUBY
    end
  end

  context "with non-literal values for the primitive flags" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        format_text("hi", static_html: flag_value, only_path: other_value)
      RUBY
    end
  end
end
