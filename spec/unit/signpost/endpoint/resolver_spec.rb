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
            { controller: 'Foo', action: Test }
          end

          it { expect(subject.endpoint).to equal(Foo::Test) }
          it { expect(subject.params).to   include(controller: Foo, action: Foo::Test) }
        end

        context 'when action as string and it is a class' do
          let(:spec) do
            { controller: 'Foo', action: 'test' }
          end

          it { expect(subject.endpoint).to equal(Foo::Test) }
          it { expect(subject.params).to   include(controller: Foo, action: Foo::Test) }
        end

        context 'with only action' do
          let(:spec) do
            { action: 'test' }
          end


          it { expect(subject.endpoint).to be_a(Signpost::Endpoint::Dynamic) }
          it { expect(subject.params).to   include(action: 'test') }
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

      context 'when class' do
        let(:spec) { Test }

        it { expect(subject.endpoint).to equal(spec) }
        it { expect(subject.params).to   eql({}) }
      end

      context 'when nil' do
        let(:spec) { {} }

        it { expect(subject.endpoint).to be_a(Signpost::Endpoint::Dynamic) }
      end
    end

    context 'with namespace' do
      context 'when with controller' do
        let(:spec) do
          { controller: 'Test', action: 'show' }
        end

        context 'when string' do
          let(:options) do
            { namespace: 'Foo' }
          end

          it 'resolves Foo::Test not Test' do
            expect(subject.endpoint).to equal(Foo::Test)
          end
        end

        context 'when symbol' do
          let(:options) do
            { namespace: :foo }
          end

          it 'resolves Foo::Test not Test' do
            expect(subject.endpoint).to equal(Foo::Test)
          end
        end
      end

      context 'when without controller' do
        let(:spec) do
          { action: 'test' }
        end

        context 'when action is a class' do
          let(:options) do
            { namespace: 'foo' }
          end

          it { expect(subject.endpoint).to equal(Foo::Test) }
        end

        context 'when action is not a class' do
          let(:options) do
            { namespace: 'test' }
          end

          it { expect(subject.endpoint).to equal(Test) }
          it { expect(subject.params).to   include(action: 'test') }
        end

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

      context 'when controller#action format' do
        let(:format) { '%{singular_name}Controller' }
        let(:spec)   { 'test#index' }

        it 'resolves endpoint' do
          expect(subject.endpoint).to equal(TestController)
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
