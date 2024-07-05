# frozen_string_literal: true

require "rubocop"

require_relative "rubocop/open_project"
require_relative "rubocop/open_project/version"
require_relative "rubocop/open_project/inject"

RuboCop::OpenProject::Inject.defaults!

require_relative "rubocop/cop/open_project_cops"
