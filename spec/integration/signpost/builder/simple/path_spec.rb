require 'spec_helper'

describe Signpost::Builder::Simple::GET do
  let(:instance) { described_class.new(pattern, options) }

  let(:pattern) { '/users/:id' }
  let(:spec) do
    { controller: 'Users', action: 'show' }
  end
  let(:options) { {} }

  let(:router) { instance_double('Signpost::Router') }
  let(:routes) { Signpost::SUPPORTED_METHODS.each_with_object({}) { |m, h| h[m] = [] }.freeze }
  let(:named_routes) { {} }

  let(:route) do
    instance.expose(router, routes, named_routes)
    routes['GET'].last
  end

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
      context 'with strings' do
        let(:spec) do
          { controller: 'Users', action: 'index' }
        end

        it { expect(route.params).to include('controller' => Users, 'action' => 'index') }
      end

      context 'with symbols' do
        let(:spec) do
          { controller: :users, action: :index }
        end

        it { expect(route.params).to include('controller' => Users, 'action' => :index) }
      end

      context 'with constants' do
        let(:spec) do
          { controller: Users, action: 'index' }
        end

        it { expect(route.params).to include('controller' => Users, 'action' => 'index') }
      end
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
      instance.to(spec).except(except)
    end

    let(:except) { '/users/42' }

    it 'should capture anything except id 42' do
      expect(route.match('/users/1', {})).to be_a(Hash)
      expect(route.match(except, {})).to     be_nil
    end
  end

  describe '#capture' do
    before(:each) do
      instance.to(spec).capture({ id: /\d+/ })
    end

    it 'should capture only digits' do
      expect(route.match('/users/42', {})).to   be_a(Hash)
      expect(route.match('/users/john', {})).to be_nil
    end
  end

  describe '#constraints' do
    context 'one constraint' do
      before(:each) do
        instance.to(spec).constraint(->(env) { env['RACK_ENV'] == 'development' })
      end
      let(:result) { route.match('/users/42', environment) }

      context 'when matches' do
        let(:environment) do
          { 'RACK_ENV' => 'development' }
        end

        it { expect(result).to be_a(Hash) }
      end

      context 'when does not matches' do
        let(:environment) do
          { 'RACK_ENV' => 'production' }
        end

        it { expect(result).to be_nil }
      end
    end

    context 'many constraints' do
      before(:each) do
        instance.to(spec).constraints(
          ->(env) { env['RACK_ENV'] == 'development' },
          ->(env) { env['admin'] }
        )
      end
      let(:result) { route.match('/users/42', environment) }

      context 'when matches' do
        let(:environment) do
          {
            'RACK_ENV' => 'development',
            'admin' => true
          }
        end

        it { expect(result).to be_a(Hash) }
      end

      context 'when does not matches' do
        let(:environment) do
          {
            'RACK_ENV' => 'development',
            'admin' => false
          }
        end

        it { expect(result).to be_nil }
      end
    end
  end

  describe '#params' do
    before(:each) do
      instance.to(spec).params(foo: 'bar')
    end

    it 'should add it to route params' do
      expect(route.match('/users/42', {})).to include('foo' => 'bar')
    end
  end

  describe 'GET' do
    let(:instance) { Signpost::Builder::Simple::Path::GET.new(pattern, options) }

    it { expect(instance.http_methods).to contain_exactly('GET') }
  end

  describe 'POST' do
    let(:instance) { Signpost::Builder::Simple::Path::POST.new(pattern, options) }

    it { expect(instance.http_methods).to contain_exactly('POST') }
  end

  describe 'PUT' do
    let(:instance) { Signpost::Builder::Simple::Path::PUT.new(pattern, options) }

    it { expect(instance.http_methods).to contain_exactly('PUT') }
  end

  describe 'PATCH' do
    let(:instance) { Signpost::Builder::Simple::Path::PATCH.new(pattern, options) }

    it { expect(instance.http_methods).to contain_exactly('PATCH') }
  end

  describe 'OPTIONS' do
    let(:instance) { Signpost::Builder::Simple::Path::OPTIONS.new(pattern, options) }

    it { expect(instance.http_methods).to contain_exactly('OPTIONS') }
  end

  describe 'DELETE' do
    let(:instance) { Signpost::Builder::Simple::Path::DELETE.new(pattern, options) }

    it { expect(instance.http_methods).to contain_exactly('DELETE') }
  end

  describe 'Any' do
    let(:instance) { Signpost::Builder::Simple::Path::Any.new(pattern, options) }

    context 'by default' do
      it { expect(instance.http_methods).to match_array(Signpost::SUPPORTED_METHODS) }
    end

    context 'when specified' do
      before(:each) do
        instance.via('GET', 'POST')
      end

      it { expect(instance.http_methods).to contain_exactly('GET', 'POST') }
    end

    context 'when specified but not valid' do
      before(:each) do
        instance.via('GET', 'post', 'BULLSHIT')
      end

      it { expect(instance.http_methods).to contain_exactly('GET', 'POST') }
    end
  end


end
