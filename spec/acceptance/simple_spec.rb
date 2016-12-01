describe 'Simple routes' do
  let(:builder) do
    Signpost::Builder.new do
      get('/dragons').to('dragons#index')
      get('/dragons/:id').to(controller: 'dragons', action: 'show')

      post('/dragons/?').to(controller: Dragons, action: 'create')

      put('/dragons/type/:id').to('dragons/types#create')

      patch('/dragons/:id').to('Dragons#edit')

      options('/dragons').to('dragons#usage')

      delete('/dragons/:id').to('dragons#destroy')

      match('/dragons/any/:type').to('Echo').params(match: true)
    end
  end

  let(:router) { builder.build }
  let(:result) { router.call(env) }
  let(:body)   { result[2][0] }

  let(:env) { Rack::MockRequest.env_for(uri, method: method) }
  let(:id)  { rand(100) }

  describe 'get' do
    let(:method) { 'GET' }

    context 'request without id' do
      let(:uri) { '/dragons' }

      it { expect(body).to eql('dragons|index') }
    end

    context 'request with id' do
      let(:uri) { "/dragons/#{id}" }

      it { expect(body).to eql("dragons|show|#{id}") }
    end

    context 'match' do
      let(:uri) { '/dragons/any/get' }

      it { expect(result['router.params']['type']).to   eql('get') }
      it { expect(result['router.params']['action']).to eql(Echo) }
      it { expect(result['router.params']['match']).to  be(true) }
    end
  end

  describe 'post' do
    let(:method) { 'POST' }

    context 'request' do
      let(:uri) { '/dragons/' }

      it { expect(body).to eql('dragons|create') }
    end

    context 'match' do
      let(:uri) { '/dragons/any/post' }

      it { expect(result['router.params']['type']).to   eql('post') }
      it { expect(result['router.params']['action']).to eql(Echo) }
      it { expect(result['router.params']['match']).to  be(true) }
    end
  end

  describe 'put' do
    let(:method) { 'PUT' }

    context 'request' do
      let(:uri) { "/dragons/type/#{id}" }

      it { expect(body).to eql("dragon-type|create|#{id}") }
    end

    context 'match' do
      let(:uri) { '/dragons/any/put' }

      it { expect(result['router.params']['type']).to   eql('put') }
      it { expect(result['router.params']['action']).to eql(Echo) }
      it { expect(result['router.params']['match']).to  be(true) }
    end
  end

  describe 'patch' do
    let(:method) { 'PATCH' }

    context 'request' do
      let(:uri) { "/dragons/#{id}" }

      it { expect(body).to eql("dragons|edit|#{id}") }
    end

    context 'match' do
      let(:uri) { '/dragons/any/patch' }
    end
  end

  describe 'delete' do
    let(:method) { 'DELETE' }

    context 'request' do
      let(:uri) { "/dragons/#{id}" }

      it { expect(body).to eql("dragons|destroy|#{id}") }
    end

    context 'match' do
      let(:uri) { '/dragons/any/delete' }
    end
  end
end
