describe 'Endpoint variants' do
  let(:builder) { Signpost::Builder.new }

  let(:id) { rand(100) }

  let(:router) { builder.build }
  let(:result) { router.call(env) }

  %w(get post put patch options delete).each do |method|
    describe "for #{method}" do
      before(:each) do
        builder.send(method, pattern).to(spec)
      end
      let(:env) { Rack::MockRequest.env_for(path, method: method) }

      describe 'string' do
        let(:pattern) { '/dragons/:id' }
        let(:path)    { "/dragons/#{id}" }

        # put('/dragons/:id').to('dragons/types#create')
        context 'when namespace, controller and action' do
          let(:spec) { 'dragons/types#create' }

          it { expect(result).to eql("dragon-type|create|#{id}") }
        end

        # put('/dragons/:id').to('Dragons::Types::Create')
        context 'when namespace and controller' do
          let(:spec) { 'Dragons::Types::Create' }

          it { expect(result).to eql("dragon-type|create|#{id}") }
        end

        # put('/dragons/:id').to('dragons#show')
        context 'when controller and action' do
          let(:spec) { 'dragons#show' }

          it { expect(result).to eql("dragons|show|#{id}") }
        end

        # put('/dragons/:id').to('Echo')
        context 'when controller' do
          let(:spec) { 'Echo' }

          it { expect(result['router.params']['id']).to eql(id.to_s) }
        end
      end

      describe 'hash' do
        let(:pattern) { '/dragons/:id' }
        let(:path) { "/dragons/#{id}" }

        # put('/dragons/:id').to({ controller: 'Dragons', action: 'create' })
        context 'when strings' do
          let(:spec) do
            { controller: 'Dragons', action: 'show' }
          end

          it { expect(result).to eql("dragons|show|#{id}") }
        end

        # put('/dragons/:id').to({ controller: 'Dragons', action: 'create' })
        context 'when symbols' do
          let(:spec) do
            { controller: :dragons, action: :show }
          end

          it { expect(result).to eql("dragons|show|#{id}") }
        end

        # put('/dragons/:id').to({ controller: Dragons, action: 'create' })
        context 'when constants' do
          let(:spec) do
            { controller: Dragons, action: 'show' }
          end

          it { expect(result).to eql("dragons|show|#{id}") }
        end

        # put('/dragons/:id').to({ controller: 'Dragon::Types', action: 'Create' })
        context 'when action is a class' do
          let(:spec) do
            { controller: 'Dragons::Types', action: 'Create' }
          end

          it { expect(result).to eql("dragon-type|create|#{id}") }
        end

        # put('/dragons/:id').to({ controller: 'Dragon::Types::Create' })
        context 'when no action' do
          let(:spec) do
            { controller: 'Dragons::Types::Create' }
          end

          it { expect(result).to eql("dragon-type|create|#{id}") }
        end
      end

      # put('/dragons/types/:id').to(Dragons::Types::Create)
      describe 'constant' do
        let(:spec)    { Dragons::Types::Create }
        let(:pattern) { '/dragons/types/:id' }
        let(:path)    { "/dragons/types/#{id}" }

        it { expect(result).to eql("dragon-type|create|#{id}") }
      end

      describe 'block' do
        let(:spec) do
          ->(env) { env['router.params']['id'] }
        end
        let(:pattern) { '/dragons/:id' }

        # put('/dragons/:id').to(->(env) { [200, {}, [env['router.params']['id']] })
        context 'when lambda' do
          let(:path) { "/dragons/#{id}" }

          it { expect(result).to eql(id.to_s) }
        end

        # put('/dragons/:id').to do |env|
        #   [200, {}, [env['router.params']['id']]
        # end
        context 'when in #to' do
          before(:each) do
            builder.send(method, '/users/:id').to do |env|
              env['router.params']['id']
            end
          end
          let(:path) { "/users/#{id}" }

          it { expect(result).to eql(id.to_s) }
        end

        # put('/users/:id') do |env|
        #   [200, {}, [env['router.params']['id']]
        # end
        context 'when without #to' do
          before(:each) do
            builder.send(method, '/users/:id') do |env|
              env['router.params']['id']
            end
          end
          let(:path) { "/users/#{id}" }

          it { expect(result).to eql(id.to_s) }
        end
      end

      describe 'dynamic' do
        # put('/dragons/:action/:id').to({ controller: 'dragons' })
        context 'when dynamic action' do
          let(:pattern) { '/dragons/:action/:id' }
          let(:spec) do
            { controller: 'dragons' }
          end
          let(:path) { "/dragons/show/#{id}" }

          it { expect(result).to eql("dragons|show|#{id}") }
        end

        # put('/:controller/:id').to({ action: 'show' })
        context 'when dynamic controller' do
          let(:pattern) { '/:controller/:id' }
          let(:spec) do
            { action: 'show' }
          end
          let(:path) { "/dragons/#{id}" }

          it { expect(result).to eql("dragons|show|#{id}") }
        end

        # put('/:controller/:action/:id')
        context 'when dynamic controller and action' do
          let(:pattern) { '/:controller/:action/:id' }
          let(:spec) { {} }
          let(:path) { "/dragons/show/#{id}" }

          it { expect(result).to eql("dragons|show|#{id}") }
        end
      end
    end
  end
end
