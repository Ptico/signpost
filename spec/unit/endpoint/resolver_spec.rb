require 'spec_helper'

describe Signpost::Endpoint::Resolver do
  let(:instance) { described_class.new(spec, options) }

  before(:all) do
    class Test; end
    class TestController; end
    class TestsController; end

    module Foo
      class Test; end
      class TestsController; end
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

    context 'without namespace and format' do
      let(:options) do
        {}
      end

      context 'when string' do
        context 'controller' do
          let(:spec) { 'test' }

          it { expect(subject.endpoint).to equal(Test) }
          it { expect(subject.params).to   include(controller: Test, action: nil) }
        end

        context 'controller#action' do
          let(:spec) { 'test#show' }

          it { expect(subject.endpoint).to equal(Test) }
          it { expect(subject.params).to   include(controller: Test, action: 'show') }
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

        context 'unresolvable string' do
          let(:spec) { 'Baz#show' }

          it { expect { subject }.to raise_error(Signpost::Endpoint::UnresolvedError) }
        end
      end

      context 'when hash' do
        context 'with controller' do
          context 'as string' do
            let(:spec) do
              { controller: 'Test' }
            end

            it { expect(subject.endpoint).to equal(Test) }
            it { expect(subject.params).to   include(controller: Test, action: nil) }
          end

          context 'as constant' do
            let(:spec) do
              { controller: Test }
            end

            it { expect(subject.endpoint).to equal(Test) }
            it { expect(subject.params).to   include(controller: Test, action: nil) }
          end
        end

        context 'with controller and action' do
          let(:spec) do
            { controller: 'Test', action: 'show' }
          end

          it { expect(subject.endpoint).to equal(Test) }
          it { expect(subject.params).to   include(controller: Test, action: 'show') }
        end

        context 'with action as constant' do
          let(:spec) do
            { controller: 'Foo', action: 'test' }
          end

          it { expect(subject.endpoint).to equal(Foo::Test) }
          it { expect(subject.params).to   include(controller: Foo, action: Foo::Test) }
        end

        context 'with unresolvable params' do
          let(:spec) do
            { controller: 'Baz', action: 'show' }
          end

          it { expect { subject }.to raise_error(Signpost::Endpoint::UnresolvedError) }
        end
      end

      context 'when block' do
        let(:spec) do
          ->(env) { env }
        end

        it { expect(subject.endpoint).to equal(spec) }
        it { expect(subject.params).to   eql({}) }
      end

      context 'when nil' do
        let(:spec) { {} }

        it { expect { subject }.to raise_error(Signpost::Endpoint::UnresolvedError) }
      end
    end

    context 'with namespace' do
      let(:options) do
        { namespace: 'Foo' }
      end

      let(:spec) do
        { controller: 'Test', action: 'show' }
      end

      it 'resolves Foo::Test not Test' do
        expect(subject.endpoint).to equal(Foo::Test)
      end
    end

    context 'with format' do
      let(:options) do
        { controller_format: format }
      end

      context '%name' do
        let(:format) { '%{name}Controller' }
        let(:spec) do
          { controller: 'Test' }
        end

        it 'uses exact name' do
          expect(subject.endpoint).to equal(TestController)
        end
      end

      context '%singular_name' do
        let(:format) { '%{singular_name}Controller' }
        let(:spec) do
          { controller: 'Tests' }
        end

        it 'uses singular name' do
          expect(subject.endpoint).to equal(TestController)
        end
      end

      context '%plural_name' do
        let(:format) { '%{plural_name}Controller' }
        let(:spec) do
          { controller: 'Test' }
        end

        it 'uses plural name' do
          expect(subject.endpoint).to equal(TestsController)
        end
      end
    end

    context 'with namespace and format' do
      let(:options) do
        {
          namespace: 'Foo',
          controller_format: '%{plural_name}Controller'
        }
      end
      let(:spec) do
        { controller: 'Test' }
      end

      it 'resolves controller by pattern in the namespace' do
        expect(subject.endpoint).to equal(Foo::TestsController)
      end
    end
  end

end
