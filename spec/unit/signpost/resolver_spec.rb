RSpec.describe Signpost::Resolver do
  let(:instance) { described_class.new(spec, namespace, format) }

  before(:all) do
    class Test
      def self.call; end
      class Bar
        def self.call; end
      end
    end
    class TestController; end
    class TestsController; end

    class Users
      def self.call; end
    end

    module Foo
      class Test
        def self.call; end
        class Index
          def self.call; end
        end
      end
      class TestController; end
      class TestsController
        class Show
          def self.call; end
        end
      end

      class PeopleController; end
      class PersonController; end

      module Bar
        class CompanyController;
          class Edit
            def self.call; end
          end
        end
        class CompaniesController; end
      end
    end
  end

  after(:all) do
    Object.send(:remove_const, :Foo)
    Object.send(:remove_const, :Test)
    Object.send(:remove_const, :TestController)
    Object.send(:remove_const, :TestsController)
  end

  describe '#resolve' do
    subject { instance.resolve }

    context 'when string' do
      context 'without namespace and format' do
        let(:namespace) { nil }
        let(:format)    { nil }

        context 'action' do
          let(:spec) { 'test' }

          it { expect(subject.endpoint).to equal(Test) }
          it { expect(subject.params).to   include(controller: nil, action: Test) }
        end

        context '::Action' do
          let(:spec) { '::Test' }

          it { expect(subject.endpoint).to equal(Test) }
          it { expect(subject.params).to   include(controller: nil, action: Test) }
        end

        context 'controller#action' do
          let(:spec) { 'test#show' }

          it { expect(subject.endpoint).to equal(Test) }
          it { expect(subject.params).to   include(controller: Test, action: 'show') }
        end

        context 'controller#action with action const' do
          let(:spec) { 'foo#test' }

          it { expect(subject.endpoint).to equal(Foo::Test) }
          it { expect(subject.params).to   include(controller: Foo, action: Foo::Test) }
        end

        context 'namespace/controller#action' do
          let(:spec) { 'foo/test#show' }

          it { expect(subject.endpoint).to equal(Foo::Test) }
          it { expect(subject.params).to   include(controller: Foo::Test, action: 'show') }
        end

        context 'Namespace::Controller#action' do
          let(:spec) { 'Foo::Test#show' }

          it { expect(subject.endpoint).to equal(Foo::Test) }
          it { expect(subject.params).to   include(controller: Foo::Test, action: 'show') }
        end

        context 'Namespace::Controller#action with action const' do
          let(:spec) { 'Foo::Test#index' }

          it { expect(subject.endpoint).to equal(Foo::Test::Index) }
          it { expect(subject.params).to   include(controller: Foo::Test, action: Foo::Test::Index) }
        end
      end

      context 'with namespace' do
        let(:namespace) { Foo }
        let(:format)    { nil }

        context 'Action' do
          let(:spec) { 'index' }

          it { expect(subject.endpoint).to equal(Foo) }
          it { expect(subject.params).to   include(controller: Foo, action: 'index') }
        end

        context 'Action as constant' do
          let(:spec) { 'Test' }

          it { expect(subject.endpoint).to equal(Foo::Test) }
          it { expect(subject.params).to   include(controller: nil, action: Foo::Test) }
        end

        context '::Action' do
          let(:spec) { '::Test' }

          it { expect(subject.endpoint).to equal(Test) }
          it { expect(subject.params).to   include(controller: nil, action: Test) }
        end

        context 'controller#action' do
          let(:spec) { 'test#show' }

          it { expect(subject.endpoint).to equal(Foo::Test) }
          it { expect(subject.params).to   include(controller: Foo::Test, action: 'show') }
        end

        context '::Controller#action' do
          let(:spec) { '::Test#show' }

          it { expect(subject.endpoint).to equal(Test) }
          it { expect(subject.params).to   include(controller: Test, action: 'show') }
        end

        context 'Controller::Class#action' do
          let(:spec) { 'Test::Index#show' }

          it { expect(subject.endpoint).to equal(Foo::Test::Index) }
          it { expect(subject.params).to   include(controller: Foo::Test::Index, action: 'show') }
        end

        context 'controller#action with action const' do
          let(:spec) { 'test#index' }

          it { expect(subject.endpoint).to equal(Foo::Test::Index) }
          it { expect(subject.params).to   include(controller: Foo::Test, action: Foo::Test::Index) }
        end
      end

      context 'with format' do
        let(:namespace) { nil }

        context '%name' do
          let(:format) { '%{name}Controller' }
          let(:spec)   { 'test#foo' }

          it { expect(subject.endpoint).to equal(TestController) }
          it { expect(subject.params).to include(controller: TestController, action: 'foo') }
        end

        context '%name with module' do
          let(:format) { 'Foo::%{name}Controller' }
          let(:spec)   { 'tests#bar' }

          it { expect(subject.endpoint).to equal(Foo::TestsController) }
          it { expect(subject.params).to include(controller: Foo::TestsController, action: 'bar') }
        end

        context '%singular_name' do
          let(:format) { '%{singular_name}Controller' }
          let(:spec)   { 'tests#foo' }

          it { expect(subject.endpoint).to equal(TestController) }
          it { expect(subject.params).to include(controller: TestController, action: 'foo') }
        end

        context '%plural_name' do
          let(:format) { '%{plural_name}Controller' }
          let(:spec)   { 'test#foo' }

          it { expect(subject.endpoint).to equal(TestsController) }
          it { expect(subject.params).to include(controller: TestsController, action: 'foo') }
        end

        context '%plural_name with only action' do
          let(:format) { '%{plural_name}Controller' }
          let(:spec)   { 'test' }

          it { expect(subject.endpoint).to equal(Test) }
          it { expect(subject.params).to include(controller: nil, action: Test) }
        end

        context '%plural_name within module' do
          let(:format) { '%{plural_name}Controller' }
          let(:spec)   { 'Foo::Person#show' }

          it { expect(subject.endpoint).to equal(Foo::PeopleController) }
          it { expect(subject.params).to include(controller: Foo::PeopleController, action: 'show') }
        end

        context '%singular_name within module' do
          let(:format) { '%{singular_name}Controller' }
          let(:spec)   { 'foo/people#show' }

          it { expect(subject.endpoint).to equal(Foo::PersonController) }
          it { expect(subject.params).to include(controller: Foo::PersonController, action: 'show') }
        end
      end

      context 'with namespace and format' do
        let(:namespace) { Foo }

        context '%name' do
          let(:format) { '%{name}Controller' }
          let(:spec)   { 'test#foo' }

          it { expect(subject.endpoint).to equal(Foo::TestController) }
          it { expect(subject.params).to include(controller: Foo::TestController, action: 'foo') }
        end

        context '%name with module' do
          let(:format) { 'Bar::%{name}Controller' }
          let(:spec)   { 'company#show' }

          it { expect(subject.endpoint).to equal(Foo::Bar::CompanyController) }
          it { expect(subject.params).to include(controller: Foo::Bar::CompanyController, action: 'show') }
        end

        context '%singular_name' do
          let(:format) { '%{singular_name}Controller' }
          let(:spec)   { 'tests#index' }

          it { expect(subject.endpoint).to equal(Foo::TestController) }
          it { expect(subject.params).to include(controller: Foo::TestController, action: 'index') }
        end

        context '%plural_name' do
          let(:format) { '%{plural_name}Controller' }
          let(:spec)   { 'test#foo' }

          it { expect(subject.endpoint).to equal(Foo::TestsController) }
          it { expect(subject.params).to include(controller: Foo::TestsController, action: 'foo') }
        end

        context '%plural_name within module' do
          let(:format) { '%{plural_name}Controller' }
          let(:spec)   { 'Bar::Company#edit' }

          it { expect(subject.endpoint).to equal(Foo::Bar::CompaniesController) }
          it { expect(subject.params).to include(controller: Foo::Bar::CompaniesController, action: 'edit') }
        end

        context '%singular_name within module' do
          let(:format) { '%{singular_name}Controller' }
          let(:spec)   { 'bar/companies#edit' }

          it { expect(subject.endpoint).to equal(Foo::Bar::CompanyController::Edit) }
          it { expect(subject.params).to include(controller: Foo::Bar::CompanyController, action: Foo::Bar::CompanyController::Edit) }
        end

        context '%plural_name with only action' do
          let(:format) { '%{plural_name}Controller' }
          let(:spec)   { 'test' }

          it { expect(subject.endpoint).to equal(Foo::Test) }
          it { expect(subject.params).to include(controller: nil, action: Foo::Test) }
        end
      end

      context 'when endpoint can not be resolved' do
        let(:format) { nil }

        context 'global controller not exists' do
          let(:spec) { 'Baz#show' }
          let(:namespace) { nil }

          it { expect { subject }.to raise_error(Signpost::Resolver::UnresolvedError) }
        end

        context 'namespaced controller absent but global exists' do
          let(:spec) { 'users#show' }
          let(:namespace) { Foo }

          it { expect { subject }.to raise_error(Signpost::Resolver::UnresolvedError) }
        end
      end
    end

    context 'when symbol' do
      context 'without namespace and format' do
        let(:namespace) { nil }
        let(:format)    { nil }
        let(:spec)      { :test }

        it { expect(subject.endpoint).to equal(Test) }
        it { expect(subject.params).to   include(controller: nil, action: Test) }
      end

      context 'with namespace (action endpoint exists)' do
        let(:namespace) { Foo }
        let(:format)    { nil }
        let(:spec)      { :test }

        it { expect(subject.endpoint).to equal(Foo::Test) }
        it { expect(subject.params).to   include(controller: nil, action: Foo::Test) }
      end

      context 'with namespace (action endpoint not exists)' do
        let(:namespace) { Foo }
        let(:format)    { nil }
        let(:spec)      { :index }

        it { expect(subject.endpoint).to equal(Foo) }
        it { expect(subject.params).to   include(controller: Foo, action: 'index') }
      end

      context 'with format' do
        let(:namespace) { nil }
        let(:format)    { '%{plural_name}Controller' }
        let(:spec)      { 'test' }

        it { expect(subject.endpoint).to equal(Test) }
        it { expect(subject.params).to include(controller: nil, action: Test) }
      end

      context 'with namespace and format' do
        let(:namespace) { Foo }
        let(:format)    { '%{plural_name}Controller' }
        let(:spec)      { :test }

        it { expect(subject.endpoint).to equal(Foo::Test) }
        it { expect(subject.params).to   include(controller: nil, action: Foo::Test) }
      end
    end

    context 'when hash' do
      context 'without namespace and format' do
        let(:namespace) { nil }
        let(:format)    { nil }

        context 'only action as string' do
          let(:spec) do
            { action: 'test' }
          end

          it { expect(subject.endpoint).to equal(Test) }
          it { expect(subject.params).to   include(controller: nil, action: Test) }
        end

        context 'only action as const' do
          let(:spec) do
            { action: Test }
          end

          it { expect(subject.endpoint).to equal(Test) }
          it { expect(subject.params).to   include(controller: nil, action: Test) }
        end

        context 'controller as string, action as string' do
          let(:spec) do
            { controller: 'test', action: 'bar' }
          end

          it { expect(subject.endpoint).to equal(Test::Bar) }
          it { expect(subject.params).to   include(controller: Test, action: Test::Bar) }
        end

        context 'controller as symbol, action as symbol' do
          let(:spec) do
            { controller: :test, action: :bar }
          end

          it { expect(subject.endpoint).to equal(Test::Bar) }
          it { expect(subject.params).to   include(controller: Test, action: Test::Bar) }
        end

        context 'controller as string with module' do
          let(:spec) do
            { controller: 'Foo::Test', action: 'edit' }
          end

          it { expect(subject.endpoint).to equal(Foo::Test) }
          it { expect(subject.params).to   include(controller: Foo::Test, action: 'edit') }
        end

        context 'controller as string with path' do
          let(:spec) do
            { controller: 'foo/test', action: 'index' }
          end

          it { expect(subject.endpoint).to equal(Foo::Test::Index) }
          it { expect(subject.params).to   include(controller: Foo::Test, action: Foo::Test::Index) }
        end

        context 'controller as const, action as string' do
          let(:spec) do
            { controller: Test, action: 'foo' }
          end

          it { expect(subject.endpoint).to equal(Test) }
          it { expect(subject.params).to   include(controller: Test, action: 'foo') }
        end

        context 'controller as const, action as const' do
          let(:spec) do
            { controller: Test, action: Test::Bar }
          end

          it { expect(subject.endpoint).to equal(Test::Bar) }
          it { expect(subject.params).to   include(controller: Test, action: Test::Bar) }
        end

        context 'controller as const, action is another const' do
          let(:spec) do
            { controller: Test, action: Users }
          end

          it { expect(subject.endpoint).to equal(Users) }
          it { expect(subject.params).to   include(controller: Test, action: Users) }
        end

        context 'controller is nil, action as string' do
          let(:spec) do
            { controller: nil, action: 'Test::Bar' }
          end

          it { expect(subject.endpoint).to equal(Test::Bar) }
          it { expect(subject.params).to   include(controller: nil, action: Test::Bar) }
        end

        context 'controller is nil, action is const' do
          let(:spec) do
            { controller: nil, action: Test::Bar }
          end

          it { expect(subject.endpoint).to equal(Test::Bar) }
          it { expect(subject.params).to   include(controller: nil, action: Test::Bar) }
        end
      end

      context 'with namespace' do
        let(:namespace) { Foo }
        let(:format)    { nil }

        context 'only action as string' do
          let(:spec) do
            { action: 'test' }
          end

          it { expect(subject.endpoint).to equal(Foo::Test) }
          it { expect(subject.params).to   include(controller: nil, action: Foo::Test) }
        end

        context 'only action as const' do
          let(:spec) do
            { action: Test }
          end

          it { expect(subject.endpoint).to equal(Test) }
          it { expect(subject.params).to   include(controller: nil, action: Test) }
        end

        context 'controller as string, action as string' do
          let(:spec) do
            { controller: 'test', action: 'index' }
          end

          it { expect(subject.endpoint).to equal(Foo::Test::Index) }
          it { expect(subject.params).to   include(controller: Foo::Test, action: Foo::Test::Index) }
        end

        context 'controller as const, action as const' do
          let(:spec) do
            { controller: Test, action: Test::Bar }
          end

          it { expect(subject.endpoint).to equal(Test::Bar) }
          it { expect(subject.params).to   include(controller: Test, action: Test::Bar) }
        end

        context 'controller as const, action is another const' do
          let(:spec) do
            { controller: Test, action: Users }
          end

          it { expect(subject.endpoint).to equal(Users) }
          it { expect(subject.params).to   include(controller: Test, action: Users) }
        end

        context 'controller is nil, action is string' do
          let(:spec) do
            { controller: nil, action: 'show' }
          end

          it { expect(subject.endpoint).to equal(Foo) }
          it { expect(subject.params).to   include(controller: Foo, action: 'show') }
        end

        context 'controller is nil, action is string pointing to constant' do
          let(:spec) do
            { controller: nil, action: 'test' }
          end

          it { expect(subject.endpoint).to equal(Foo::Test) }
          it { expect(subject.params).to   include(controller: nil, action: Foo::Test) }
        end

        context 'controller is nil, action is const' do
          let(:spec) do
            { controller: nil, action: Users }
          end

          it { expect(subject.endpoint).to equal(Users) }
          it { expect(subject.params).to   include(controller: nil, action: Users) }
        end
      end

      context 'with format' do
        let(:namespace) { nil }

        context '%name' do
          let(:format) { '%{name}Controller' }
          let(:spec) do
            { controller: 'test', action: 'index' }
          end

          it { expect(subject.endpoint).to equal(TestController) }
          it { expect(subject.params).to include(controller: TestController, action: 'index') }
        end

        context '%name with module' do
          let(:format) { 'Foo::%{name}Controller' }
          let(:spec) do
            { controller: 'tests', action: 'show' }
          end

          it { expect(subject.endpoint).to equal(Foo::TestsController::Show) }
          it { expect(subject.params).to include(controller: Foo::TestsController, action: Foo::TestsController::Show) }
        end

        context '%singular_name' do
          let(:format) { '%{singular_name}Controller' }
          let(:spec) do
            { controller: 'Tests', action: 'foo' }
          end

          it { expect(subject.endpoint).to equal(TestController) }
          it { expect(subject.params).to include(controller: TestController, action: 'foo') }
        end

        context '%plural_name' do
          let(:format) { '%{plural_name}Controller' }
          let(:spec) do
            { controller: 'test', action: 'show' }
          end

          it { expect(subject.endpoint).to equal(TestsController) }
          it { expect(subject.params).to include(controller: TestsController, action: 'show') }
        end

        context '%plural_name within module' do
          let(:format) { '%{plural_name}Controller' }
          let(:spec) do
            { controller: 'Foo::Person', action: 'show' }
          end

          it { expect(subject.endpoint).to equal(Foo::PeopleController) }
          it { expect(subject.params).to include(controller: Foo::PeopleController, action: 'show') }
        end

        context '%singular_name within module' do
          let(:format) { '%{singular_name}Controller' }
          let(:spec) do
            { controller: 'foo/people', action: 'show' }
          end

          it { expect(subject.endpoint).to equal(Foo::PersonController) }
          it { expect(subject.params).to include(controller: Foo::PersonController, action: 'show') }
        end
      end

      context 'with namespace and format' do
        let(:namespace) { Foo }

        context '%name' do
          let(:format) { '%{name}Controller' }
          let(:spec) do
            { controller: 'test', action: 'foo' }
          end

          it { expect(subject.endpoint).to equal(Foo::TestController) }
          it { expect(subject.params).to include(controller: Foo::TestController, action: 'foo') }
        end

        context '%name and constant' do
          let(:format) { '%{name}Controller' }
          let(:spec) do
            { controller: Test, action: 'bar' }
          end

          it { expect(subject.endpoint).to equal(Test::Bar) }
          it { expect(subject.params).to include(controller: Test, action: Test::Bar) }
        end

        context '%name with module' do
          let(:format) { 'Bar::%{name}Controller' }
          let(:spec) do
            { controller: 'company', action: 'show' }
          end

          it { expect(subject.endpoint).to equal(Foo::Bar::CompanyController) }
          it { expect(subject.params).to include(controller: Foo::Bar::CompanyController, action: 'show') }
        end

        context '%singular_name' do
          let(:format) { '%{singular_name}Controller' }
          let(:spec) do
            { controller: 'people', action: 'index' }
          end

          it { expect(subject.endpoint).to equal(Foo::PersonController) }
          it { expect(subject.params).to include(controller: Foo::PersonController, action: 'index') }
        end

        context '%plural_name' do
          let(:format) { '%{plural_name}Controller' }
          let(:spec) do
            { controller: 'person', action: 'index' }
          end

          it { expect(subject.endpoint).to equal(Foo::PeopleController) }
          it { expect(subject.params).to include(controller: Foo::PeopleController, action: 'index') }
        end

        context '%plural_name within module' do
          let(:format) { '%{plural_name}Controller' }
          let(:spec) do
            { controller: 'Bar::Company', action: 'edit' }
          end

          it { expect(subject.endpoint).to equal(Foo::Bar::CompaniesController) }
          it { expect(subject.params).to include(controller: Foo::Bar::CompaniesController, action: 'edit') }
        end

        context '%singular_name within module' do
          let(:format) { '%{singular_name}Controller' }
          let(:spec) do
            { controller: 'bar/companies', action: 'edit' }
          end

          it { expect(subject.endpoint).to equal(Foo::Bar::CompanyController::Edit) }
          it { expect(subject.params).to include(controller: Foo::Bar::CompanyController, action: Foo::Bar::CompanyController::Edit) }
        end
      end
    end

    context 'when class' do
      context 'without namespace and format' do
        let(:namespace) { nil }
        let(:format)    { nil }
        let(:spec)      { Users }

        it { expect(subject.endpoint).to equal(Users) }
        it { expect(subject.params).to include(controller: nil, action: Users) }
      end

      context 'with namespace' do
        let(:namespace) { 'Foo' }
        let(:format)    { nil }
        let(:spec)      { Test }

        it { expect(subject.endpoint).to equal(Test) }
        it { expect(subject.endpoint).to_not equal(Foo::Test) }

        it { expect(subject.params).to include(controller: nil, action: Test) }
      end

      context 'with format' do
        let(:namespace) { nil }
        let(:format)    { '%{singular_name}Controller' }
        let(:spec)      { Test }

        it { expect(subject.endpoint).to equal(Test) }
        it { expect(subject.params).to include(controller: nil, action: Test) }
      end

      context 'with namespace and format' do
        let(:namespace) { 'Foo' }
        let(:format)    { '%{singular_name}Controller' }
        let(:spec)      { Test }

        it { expect(subject.endpoint).to equal(Test) }
        it { expect(subject.params).to include(controller: nil, action: Test) }
      end
    end

    context 'when block' do
      context 'without namespace and format' do
        let(:namespace) { nil }
        let(:format)    { nil }
        let(:spec) do
          ->(env) { env }
        end

        it { expect(subject.endpoint).to equal(spec) }
        it { expect(subject.params).to include(controller: nil, action: spec) }
      end

      context 'with namespace' do
        let(:namespace) { 'Foo' }
        let(:format)    { nil }
        let(:spec) do
          ->(env) { env }
        end

        it { expect(subject.endpoint).to equal(spec) }
        it { expect(subject.params).to include(controller: nil, action: spec) }
      end

      context 'with format' do
        let(:namespace) { nil }
        let(:format)    { '%{singular_name}Controller' }
        let(:spec) do
          ->(env) { env }
        end

        it { expect(subject.endpoint).to equal(spec) }
        it { expect(subject.params).to include(controller: nil, action: spec) }
      end

      context 'with namespace and format' do
        let(:namespace) { 'Foo' }
        let(:format)    { '%{singular_name}Controller' }
        let(:spec) do
          ->(env) { env }
        end

        it { expect(subject.endpoint).to equal(spec) }
        it { expect(subject.params).to include(controller: nil, action: spec) }
      end
    end

    context 'when nil' do

    end
  end
end
