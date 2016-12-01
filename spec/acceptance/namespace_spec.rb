describe 'Namespaces' do
  let(:builder) do
    Signpost::Builder.new do
      namespace(:magic) do
        root.to('dragons#index')

        get('dragons').to('dragons#index').as(:dragons_list)

        namespace(:dragons) do
          put('types/:id').to('types#create').as(:create, :type)
        end
      end

      get('/magic/unicorns').to('unicorns#index')
    end
  end

  let(:router) { builder.build }
  let(:result) { router.call(env) }
  let(:body)   { result[2][0] }

  let(:named_routes) { router.named_routes.keys }

  let(:env) { Rack::MockRequest.env_for(uri, method: method) }
  let(:id)  { rand(100) }

  describe 'simple routes' do
    let(:method) { 'GET' }
    let(:uri)    { '/magic/dragons' }

    it 'resolves constant under namespace' do
      expect(body).to eql('magic/dragons|index')
    end

    it 'prepends namespace to name' do
      expect(named_routes).to_not include(:dragons_list)
      expect(named_routes).to     include(:magic_dragons_list)
    end
  end

  describe 'root route' do
    let(:method) { 'GET' }
    let(:uri)    { '/magic/' }

    it 'adds root path' do
      expect(body).to eql('magic/dragons|index')
    end

    it 'adds root named route' do
      expect(named_routes).to_not include(:root)
      expect(named_routes).to     include(:magic_root)
    end
  end

  describe 'nested namespace' do
    let(:method) { 'PUT' }
    let(:uri)    { "/magic/dragons/types/#{id}" }

    it 'resolves constant under nested namespace' do
      expect(body).to eql("magic/dragon-type|create|#{id}")
    end

    it 'prepends and appends names to nested namespaces' do
      expect(named_routes).to_not include(:magic_dragons_create_type)
      expect(named_routes).to     include(:create_magic_dragons_type)
    end
  end

end
