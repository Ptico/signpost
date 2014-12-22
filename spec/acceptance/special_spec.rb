describe 'Special routes' do
  let(:builder) do
    Signpost::Builder.new do
      get('/').to('dragons#index')

      root.to('unicorns#index')
    end
  end

  let(:router) { builder.build }
  let(:result) { router.call(env) }

  let(:env) { Rack::MockRequest.env_for(uri, method: method) }
  let(:id)  { rand(100) }

  describe 'root' do
    let(:method) { 'GET' }
    let(:uri)    { '/' }

    it 'should match root first' do
      expect(result).to eql('unicorns|index')
    end
  end

end
