# frozen_string_literal: true

RSpec.describe RuboCop::Cop::OpenProject::NoParamsInWorkPackageWhereId, :config do
  let(:config) { RuboCop::Config.new }

  context "when the value is params[...] directly" do
    it "registers an offense and autocorrects to where_display_id_in" do
      expect_offense(<<~RUBY)
        WorkPackage.where(id: params[:work_package_id])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/NoParamsInWorkPackageWhereId: #{described_class::MSG}
      RUBY

      expect_correction(<<~RUBY)
        WorkPackage.where_display_id_in(params[:work_package_id])
      RUBY
    end
  end

  context "when the value is `params[...] || params[...]`" do
    it "registers an offense and autocorrects" do
      expect_offense(<<~RUBY)
        WorkPackage.where(id: params[:work_package_id] || params[:ids])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/NoParamsInWorkPackageWhereId: #{described_class::MSG}
      RUBY

      expect_correction(<<~RUBY)
        WorkPackage.where_display_id_in(params[:work_package_id] || params[:ids])
      RUBY
    end
  end

  context "when the receiver is a chain rooted at WorkPackage" do
    it "registers an offense for an includes chain" do
      expect_offense(<<~RUBY)
        WorkPackage.includes(:project).where(id: params[:ids])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/NoParamsInWorkPackageWhereId: #{described_class::MSG}
      RUBY

      expect_correction(<<~RUBY)
        WorkPackage.includes(:project).where_display_id_in(params[:ids])
      RUBY
    end

    it "registers an offense for a deeper chain" do
      expect_offense(<<~RUBY)
        WorkPackage.visible(user).order(:id).where(id: params[:ids])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/NoParamsInWorkPackageWhereId: #{described_class::MSG}
      RUBY

      expect_correction(<<~RUBY)
        WorkPackage.visible(user).order(:id).where_display_id_in(params[:ids])
      RUBY
    end
  end

  context "when the receiver is an association ending in work_packages" do
    it "registers an offense for `project.work_packages.where(id: params[...])`" do
      expect_offense(<<~RUBY)
        project.work_packages.where(id: params[:work_package_id])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/NoParamsInWorkPackageWhereId: #{described_class::MSG}
      RUBY

      expect_correction(<<~RUBY)
        project.work_packages.where_display_id_in(params[:work_package_id])
      RUBY
    end

    it "registers an offense for an `_work_packages`-suffixed association" do
      expect_offense(<<~RUBY)
        current_user.assigned_work_packages.where(id: params[:ids])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/NoParamsInWorkPackageWhereId: #{described_class::MSG}
      RUBY

      expect_correction(<<~RUBY)
        current_user.assigned_work_packages.where_display_id_in(params[:ids])
      RUBY
    end

    it "registers an offense when the association is followed by a chain" do
      expect_offense(<<~RUBY)
        project.work_packages.includes(:project).where(id: params[:ids])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/NoParamsInWorkPackageWhereId: #{described_class::MSG}
      RUBY

      expect_correction(<<~RUBY)
        project.work_packages.includes(:project).where_display_id_in(params[:ids])
      RUBY
    end

    it "does not register an offense for an unrelated association name" do
      expect_no_offenses(<<~RUBY)
        project.users.where(id: params[:id])
      RUBY
    end
  end

  context "when params is wrapped in a method call (non-autocorrectable)" do
    it "registers an offense without an autocorrection" do
      expect_offense(<<~RUBY)
        WorkPackage.where(id: params[:id].to_i)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ OpenProject/NoParamsInWorkPackageWhereId: #{described_class::MSG}
      RUBY

      expect_no_corrections
    end
  end

  context "when the predicate key is not :id" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        WorkPackage.where(project_id: params[:project_id])
      RUBY
    end
  end

  context "when the value is a primary-key literal" do
    it "does not register an offense for an integer" do
      expect_no_offenses(<<~RUBY)
        WorkPackage.where(id: 42)
      RUBY
    end

    it "does not register an offense for an integer array" do
      expect_no_offenses(<<~RUBY)
        WorkPackage.where(id: [1, 2, 3])
      RUBY
    end
  end

  context "when the value is a subquery or scope chain" do
    it "does not register an offense for a select subquery" do
      expect_no_offenses(<<~RUBY)
        WorkPackage.where(id: other_scope.select(:id))
      RUBY
    end

    it "does not register an offense for a pluck array" do
      expect_no_offenses(<<~RUBY)
        WorkPackage.where(id: other_scope.pluck(:id))
      RUBY
    end
  end

  context "when the receiver is not WorkPackage-rooted" do
    it "does not register an offense for a different model" do
      expect_no_offenses(<<~RUBY)
        Project.where(id: params[:id])
      RUBY
    end

    it "does not register an offense for an unknown receiver" do
      expect_no_offenses(<<~RUBY)
        some_relation.where(id: params[:id])
      RUBY
    end

    it "does not register an offense for a namespaced WorkPackage constant" do
      expect_no_offenses(<<~RUBY)
        Foo::WorkPackage.where(id: params[:id])
      RUBY
    end
  end

  context "when the call is not where" do
    it "does not register an offense for find" do
      expect_no_offenses(<<~RUBY)
        WorkPackage.find(params[:id])
      RUBY
    end
  end
end
