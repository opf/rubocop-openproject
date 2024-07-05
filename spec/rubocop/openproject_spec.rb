# frozen_string_literal: true

require "spec_helper"

RSpec.describe RuboCop::OpenProject do
  it "has a version number" do
    expect(RuboCop::OpenProject::VERSION).not_to be nil
  end
end
