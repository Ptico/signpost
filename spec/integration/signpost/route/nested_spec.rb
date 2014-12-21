require 'spec_helper'

describe Signpost::Route::Nested do
  let(:instance) { described_class.new(subpath, router) }

  let(:subpath) { '/magic' }
  let(:router) do
    Signpost::Builder.new(nested: true, subroute: subpath) do
      get('/unicorns').to('Unicorns#index')
    end.build
  end

  let(:env) { Rack::MockRequest.env_for(uri, method: 'GET') }

  let(:result) { instance.match(uri, env) }

  context 'when matches' do
    let(:uri) { '/magic/unicorns' }

    it { expect(result).to eql('unicorns|index') }
  end

  context 'when subpath not matches' do
    let(:uri) { '/awesome/unicorns' }

    it { expect(result).to be_nil }
  end

  context 'when route not found' do
    let(:uri) { '/magic/rainbows' }

    it { expect(result).to be_nil }
  end
end
