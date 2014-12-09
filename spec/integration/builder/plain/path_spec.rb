require 'spec_helper'

describe Signpost::Builder::Plain::Path do
  let(:instance) { described_class.new(pattern, options) }

  let(:pattern) { '/users/:id' }
  let(:spec) do
    { controller: 'Users', action: 'show' }
  end
  let(:options) { {} }

  let(:route) { instance.build }

  before(:each) do
    class Users; end
    class UsersController; end
    module Admin
      class Users; end
      class UsersController; end
    end

    instance.to(spec)
  end

  after(:each) do
    Object.send(:remove_const, :Users)
    Object.send(:remove_const, :UsersController)
    Object.send(:remove_const, :Admin)
  end

  describe '#to' do
    context 'when string' do
      let(:spec) { 'users#show' }

      it { expect(route.params).to include('controller' => Users, 'action' => 'show') }
    end

    context 'when hash' do
      let(:spec) do
        { controller: 'Users', action: 'index' }
      end

      it { expect(route.params).to include('controller' => Users, 'action' => 'index') }
    end

    context 'when proc' do
      let(:spec) do
        ->(env) { env }
      end

      it { expect(route.endpoint).to equal(spec) }
    end

    context 'when namespace given' do
      let(:options) do
        { namespace: 'Admin' }
      end
      let(:spec) do
        { controller: 'Users', action: 'index' }
      end

      it { expect(route.params).to include('controller' => Admin::Users, 'action' => 'index') }
    end

    context 'when controller pattern given' do
      let(:options) do
        { controller_format: '%{name}Controller' }
      end
      let(:spec) do
        { controller: 'Users', action: 'show' }
      end

      it { expect(route.params).to include('controller' => UsersController, 'action' => 'show') }
    end

    context 'when namespace and controller pattern given' do
      let(:options) do
        {
          controller_format: '%{name}Controller',
          namespace: 'Admin'
        }
      end
      let(:spec) do
        { controller: 'Users', action: 'show' }
      end

      it { expect(route.params).to include('controller' => Admin::UsersController, 'action' => 'show') }
    end
  end

  describe '#as' do
    before(:each) do
      instance.to(spec).as(name)
    end
    let(:name) { :user }

    it { expect(route.name).to equal(name) }
  end

  describe '#except' do
    before(:each) do
      instance.except(path)
    end
  end

  describe '#capture' do

  end

  describe '#params' do

  end

end
