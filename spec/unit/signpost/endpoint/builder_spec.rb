require 'spec_helper'

describe Signpost::Endpoint::Builder do
  let(:instance) { described_class.new(endpoint, middlewares) }

  let(:endpoint) { ->(env) { env } }

  describe '#build' do
    subject { instance.build }

    context 'when middleware list is empty' do
      let(:middlewares) { [] }

      it 'returns endpoint' do
        expect(subject).to equal(endpoint)
      end
    end

    context 'when middleware list is not empty' do
      let(:m1) { double }
      let(:m2) { double }

      let(:blk) do
        -> { 'foo' }
      end

      let(:middlewares) do
        [
          instance_double('Signpost::Middleware', middleware: m1, args: ['foo', 'bar'], block: blk),
          instance_double('Signpost::Middleware', middleware: m2, args: [], block: nil)
        ]
      end

      before(:each) do
        allow(m1).to receive(:new)
        allow(m2).to receive(:new)
      end

      after(:each) do
        subject
      end

      it 'should build stack' do
        expect(m1).to receive(:new).with('m2', 'foo', 'bar')
        expect(m2).to receive(:new).with(endpoint).and_return('m2')
      end
    end
  end

end
