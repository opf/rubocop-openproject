# frozen_string_literal: true

RSpec.describe RuboCop::Cop::OpenProject::NoDoEndBlockWithRSpecCapybaraMatcherInExpect, :config do
  let(:config) { RuboCop::Config.new }

  context "when using `do .. end` syntax with rspec matcher" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        expect(page).to have_selector("input") do |input|
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/NoDoEndBlockWithRSpecCapybaraMatcherInExpect: The `do .. end` block is associated with `to` and not with Capybara matcher `have_selector`.
        end
      RUBY
    end

    it "matches only Capybara matchers" do
      expect_no_offenses(<<~RUBY)
        expect(foo).to have_received(:bar) do |value|
          value == 'hello world'
        end
      RUBY
    end
  end

  context "when using `{ .. }` syntax with rspec matcher" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        expect(page).to have_selector("input") { |input| }
      RUBY
    end
  end
end
