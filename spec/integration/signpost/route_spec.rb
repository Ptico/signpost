require 'spec_helper'

describe Signpost::Route do
  let(:instance) { described_class.new(matcher, stack, params, name) }

  let(:matcher) { Mustermann.new(template) }
  let(:stack) do
    spy('controller')
  end
  let(:params) do
    {
      controller: 'Users',
      action:     'show'
    }
  end
  let(:name) { :root }

  let(:template) { '/users/:id' }

  describe '#match' do
    subject { instance.match(path) }

    context 'when matches' do
      let(:template) { '/users/:id' }
      let(:path)     { '/users/2' }

      it 'should merge match data with params' do
        expect(subject).to match('controller' => 'Users', 'action' => 'show', 'id' => '2')
      end
    end

    context 'when matches and data have info about action' do
      let(:template) { '/users/:action/:id' }
      let(:path)     { '/users/view/2' }

      it 'should overwrite params with match data' do
        expect(subject).to match('controller' => 'Users', 'action' => 'view', 'id' => '2')
      end
    end

    context 'when matches and data have info about controller and action' do
      let(:template) { '/:controller/:action/:id' }
      let(:path)     { '/people/view/2' }

      it 'should overwrite params with match data' do
        expect(subject).to match('controller' => 'people', 'action' => 'view', 'id' => '2')
      end
    end

    context 'when not matches' do
      let(:template) { '/users/:id' }
      let(:path)     { '/users' }

      it { expect(subject).to be_nil }
    end
  end

  describe '#expand' do
    subject { instance.expand({ id: 42 }) }

    it { expect(subject).to eql('/users/42') }
  end

end
