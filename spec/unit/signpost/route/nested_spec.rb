require 'spec_helper'

describe Signpost::Route::Nested do
  let(:instance) { described_class.new(subpath, router) }

  let(:subpath) { '/admin' }
  let(:router)  { instance_double('Signpost::Router') }

  describe '#subpath' do
    subject { instance.subpath }

    it { expect(subject).to eql(subpath) }
  end

  describe '#match' do
    subject { instance.match(path, env) }

    let(:env) do
      { 'PATH_INFO' => '/admin/pages' }
    end

    before(:each) do
      allow(router).to receive(:call).with(env).and_return('success')
    end

    context 'when matches' do
      let(:path) { '/admin/pages' }

      it { expect(subject).to eql('success') }
    end

    context 'when does not matches' do
      let(:path) { '/users/pages' }

      it { expect(subject).to be_nil }
    end
  end

end
