# frozen_string_literal: true

require_relative "open_project/version"
require "yaml"

module RuboCop
  # This module contains custom RuboCop cops and configuration for the OpenProject project.
  # It loads the default configuration from a YAML file and sets up necessary constants.
  module OpenProject
    class Error < StandardError; end
    # Your code goes here...
    PROJECT_ROOT   = Pathname.new(__dir__).parent.parent.expand_path.freeze
    CONFIG_DEFAULT = PROJECT_ROOT.join("config", "default.yml").freeze
    CONFIG         = YAML.safe_load(CONFIG_DEFAULT.read).freeze

    private_constant(:CONFIG_DEFAULT, :PROJECT_ROOT)
  end
end
