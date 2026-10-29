# frozen_string_literal: true

RSpec.describe RuboCop::Cop::OpenProject::TestSelectorSystemArgument, :config do
  let(:cop_config) do
    {
      "ComponentNamespaces" => %w[Primer OpPrimer],
      "AdditionalComponents" => %w[Shares::PermissionButtonComponent],
      "ForwardingHelpers" => %w[flex_layout],
      "IgnoredNestedArguments" => %w[form_arguments filter_input_arguments],
      "IgnoredComponents" => %w[Primer::Alpha::TextField],
      "IgnoredSlots" => %w[with_filter_input]
    }
  end

  it "corrects a sole symbol key on a Primer component" do
    expect_offense(<<~RUBY)
      Primer::Beta::Button.new(scheme: :primary, data: { test_selector: "save" })
                                                         ^^^^^^^^^^^^^^^^^^^^^ #{described_class::MSG}
    RUBY

    expect_correction(<<~RUBY)
      Primer::Beta::Button.new(scheme: :primary, test_selector: "save")
    RUBY
  end

  it "corrects a quoted symbol key and keeps the other data attributes" do
    expect_offense(<<~RUBY)
      Primer::Beta::Button.new(data: { "test-selector": "save", turbo: true })
                                       ^^^^^^^^^^^^^^^^^^^^^^^ #{described_class::MSG}
    RUBY

    expect_correction(<<~RUBY)
      Primer::Beta::Button.new(test_selector: "save", data: { turbo: true })
    RUBY
  end

  it "corrects a string key in last position" do
    expect_offense(<<~RUBY)
      ::OpPrimer::InsetBoxComponent.new(data: { turbo: true, "test-selector" => name })
                                                             ^^^^^^^^^^^^^^^^^^^^^^^ #{described_class::MSG}
    RUBY

    expect_correction(<<~RUBY)
      ::OpPrimer::InsetBoxComponent.new(test_selector: name, data: { turbo: true })
    RUBY
  end

  it "corrects a key in the middle of a multi-line data hash" do
    expect_offense(<<~RUBY)
      Primer::Beta::Button.new(
        data: {
          turbo: true,
          test_selector: "save-\#{id}",
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{described_class::MSG}
          action: "click->x#y"
        }
      )
    RUBY

    expect_correction(<<~RUBY)
      Primer::Beta::Button.new(
        test_selector: "save-\#{id}",
        data: {
          turbo: true,
          action: "click->x#y"
        }
      )
    RUBY
  end

  it "corrects a flat data-test-selector keyword" do
    expect_offense(<<~RUBY)
      Primer::Beta::Text.new("data-test-selector": "title")
                             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{described_class::MSG}
    RUBY

    expect_correction(<<~RUBY)
      Primer::Beta::Text.new(test_selector: "title")
    RUBY
  end

  it "corrects slot calls, including safe navigation" do
    expect_offense(<<~RUBY)
      menu&.with_item(label: "Edit", data: { test_selector: "edit" })
                                             ^^^^^^^^^^^^^^^^^^^^^ #{described_class::MSG}
    RUBY

    expect_correction(<<~RUBY)
      menu&.with_item(label: "Edit", test_selector: "edit")
    RUBY
  end

  it "corrects inside nested *_arguments hashes" do
    expect_offense(<<~RUBY)
      menu.with_item(label: "Edit", content_arguments: { data: { test_selector: "edit" } })
                                                                 ^^^^^^^^^^^^^^^^^^^^^ #{described_class::MSG}
    RUBY

    expect_correction(<<~RUBY)
      menu.with_item(label: "Edit", content_arguments: { test_selector: "edit" })
    RUBY
  end

  it "corrects configured components and forwarding helpers" do
    expect_offense(<<~RUBY)
      Shares::PermissionButtonComponent.new(share: share, data: { "test-selector": "role" })
                                                                  ^^^^^^^^^^^^^^^^^^^^^^^ #{described_class::MSG}
      flex_layout(data: { test_selector: "layout" }) { }
                          ^^^^^^^^^^^^^^^^^^^^^^^ #{described_class::MSG}
    RUBY

    expect_correction(<<~RUBY)
      Shares::PermissionButtonComponent.new(share: share, test_selector: "role")
      flex_layout(test_selector: "layout") { }
    RUBY
  end

  it "registers without correcting when test_selector is already given" do
    expect_offense(<<~RUBY)
      Primer::Beta::Button.new(test_selector: "a", data: { test_selector: "b" })
                                                           ^^^^^^^^^^^^^^^^^^ #{described_class::MSG}
    RUBY

    expect_no_corrections
  end

  it "ignores ignored nested arguments" do
    expect_no_offenses(<<~RUBY)
      menu.with_item(label: "Delete", form_arguments: { data: { test_selector: "delete" } })
    RUBY
  end

  it "ignores form controls, which do not honour test_selector" do
    expect_no_offenses(<<~RUBY)
      Primer::Alpha::TextField.new(name: :q, label: "Search", data: { test_selector: "search" })
      header.with_filter_input(name: :q, label: "Filter", data: { test_selector: "filter" })
      Primer::OpenProject::FilterableTreeView.new(filter_input_arguments: { data: { test_selector: "filter" } })
    RUBY
  end

  it "ignores calls that are not components" do
    expect_no_offenses(<<~RUBY)
      link_to "Save", path, data: { test_selector: "save" }
      content_tag(:div, data: { "test-selector": "box" })
      component_wrapper(data: { test_selector: "wrapper" })
      f.text_field(name: :subject, data: { test_selector: "subject" })
      Foo::BarComponent.new(data: { test_selector: "bar" })
      menu_options(label: "x", content_args: {}, data: { "test-selector" => "x" })
    RUBY
  end

  it "ignores data passed as a variable" do
    expect_no_offenses(<<~RUBY)
      Primer::Beta::Button.new(data: button_data)
    RUBY
  end

  it "ignores the system argument itself" do
    expect_no_offenses(<<~RUBY)
      Primer::Beta::Button.new(test_selector: "save", data: { turbo: true })
    RUBY
  end
end
