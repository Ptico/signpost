require 'spec_helper'
require 'mustermann/sinatra'

describe Signpost::Route::Simple do
  let(:instance) { described_class.new(matcher, stack, params, constraints, name) }

  let(:matcher) { instance_double('Mustermann::Sinatra') }
  let(:stack) do
    ->(env) { env }
  end
  let(:params) do
    {
      controller: 'Users',
      action:     'show'
    }
  end
  let(:constraints) { [] }
  let(:name) { :root }

  describe '#params' do
    subject { instance.params }

    it 'should stringify keys' do
      expect(subject).to include('controller' => 'Users', 'action' => 'show')
    end
  end

  describe '#name' do
    subject { instance.name }

    context 'defaults to nil' do
      let(:instance) { described_class.new(matcher, stack, params) }

      it { expect(subject).to be_nil }
    end

    context 'when name given' do
      it { expect(subject).to equal(name) }
    end
  end

  describe '#endpoint' do
    subject { instance.endpoint }

    it { expect(subject).to equal(stack) }
  end

  describe '#match' do
    subject { instance.match(path, {}) }

    let(:path) { '/users/2' }

    before(:each) do
      allow(matcher).to receive(:match).with(path).and_return(match_data)
    end

    context 'when matches' do
      let(:match_data) { instance_double('MatchData', names: ['id'], captures: ['2']) }

      it { expect(subject).to include('controller' => 'Users', 'action' => 'show', 'id' => '2') }
    end

    context 'when matches and data have info about action' do
      let(:match_data) { instance_double('MatchData', names: %w(action id), captures: %w(watch 2)) }

      it 'must merge pattern data' do
        expect(subject).to include('controller' => 'Users', 'action' => 'watch', 'id' => '2')
      end
    end

    context 'when matches and data have info about controller and action' do
      let(:match_data) { instance_double('MatchData', names: %w(controller action id), captures: %w(people watch 2)) }

      it 'must merge pattern data' do
        expect(subject).to include('controller' => 'people', 'action' => 'watch', 'id' => '2')
      end
    end

    context 'with constraints' do
      let(:match_data) { instance_double('MatchData', names: [], captures: []) }

      context 'when matches' do
        let(:constraints) do
          [
            ->(env) { true },
            ->(env) { env }
          ]
        end

        it { expect(subject).to be_a(Hash) }
      end

      context 'when not matches' do
        let(:constraints) do
          [
            ->(env) { true },
            ->(env) { false }
          ]
        end

        it { expect(subject).to be_nil }
      end
    end

    context 'when not matches' do
      let(:match_data) { nil }

      it { expect(subject).to be_nil }
    end
  end

  describe '#expand' do
    subject { instance.expand(data) }

    let(:data) do
      { id: 2 }
    end
    let(:path) { '/users/2' }

    before(:each) do
      allow(matcher).to receive(:expand).with(data).and_return(path)
    end

    it { expect(subject).to eql('/users/2') }
  end

end
