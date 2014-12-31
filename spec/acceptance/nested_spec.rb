describe 'Nested routes' do
  let(:builder) do
    Signpost::Builder.new do
      within('/magic') do
        get('/dragons').to('dragons#index')

        within('/types') do
          put('/dragons/:id').to('dragons/types#create')
        end
      end

      within('/admin') do
        use AuthMiddleware, 'dumbledore', 'cribble-crable'
        use PrependMiddleware, 'admin|'

        root.to('dragons#index')
      end

      get('/magic/unicorns').to('unicorns#index')
    end
  end

  let(:router) { builder.build }
  let(:result) { router.call(env) }

  let(:env) { Rack::MockRequest.env_for(uri, method: method) }
  let(:id)  { rand(100) }

  describe 'simple routes' do
    let(:method) { 'GET' }
    let(:uri)    { '/magic/dragons' }

    it { expect(result).to eql('dragons|index') }
  end

  describe 'nested routes' do
    let(:method) { 'PUT' }
    let(:uri)    { "/magic/types/dragons/#{id}" }

    it { expect(result).to eql("dragon-type|create|#{id}") }
  end

  describe 'middlewares' do
    let(:method) { 'GET' }
    let(:uri) { '/admin/' }

    context 'when auth pass' do
      before(:each) do
        env['username'] = 'dumbledore'
        env['password'] = 'cribble-crable'
      end

      it { expect(result).to eql('admin|dragons|index') }
    end

    context 'when auth not pass' do
      before(:each) do
        env['username'] = 'voldemort'
        env['password'] = 'imlord'
      end

      it { expect(result).to eql(403) }
    end
  end

  context 'route after within' do
    let(:method) { 'GET' }
    let(:uri)    { '/magic/unicorns' }

    it { expect(result).to eql('unicorns|index') }
  end

  context 'root inside nested' do
    subject { router.named_routes.keys }

    it { expect(subject).to_not include(:root) }
  end

end
