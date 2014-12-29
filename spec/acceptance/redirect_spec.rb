describe 'Redirection' do
  let(:builder) do
    Signpost::Builder.new(options) do
      redirect('/horses').to('/unicorns').permanent
      redirect('/ponies').to('/unicorns')
      redirect('/zebras').to('/unicorns').with_status(307)

      redirect('/horses/:id') do
        "/horses/#{params['id']}/#{env['REQUEST_METHOD']}"
      end
      redirect('/ponies/:id') do
        expand(:show_unicorn, params)
      end

      redirect('/birds/:type/:id').to('/dragons/:id')

      redirect('/birds/:id').to('/dragons/:id')
      redirect('/zebras/:id').to(:show_unicorn)

      redirect('/goats/:type/:id').to('/unicorns/:id', :append)
      redirect('/goats/:id').to('/unicorns/{id}')

      get('/unicorns/:id').to('unicorns#show').as(:show_unicorn)
    end
  end

  let(:options) { {} }

  let(:router) { builder.build }
  let(:result) { router.call(env) }

  let(:env) { Rack::MockRequest.env_for(uri, method: method) }
  let(:id)  { rand(100) }

  let(:status)   { result[0] }
  let(:location) { result[1]['Location'] }
  let(:body)     { result[2] }

  describe 'simple redirections' do
    let(:method) { 'GET' }

    context 'simple permanent redirect' do
      let(:uri) { '/horses' }

      it { expect(status).to   eql(301) }
      it { expect(location).to eql('/unicorns') }
      it { expect(body).to     be_empty }
    end

    context 'simple temporary redirect' do
      let(:uri) { '/ponies' }

      it { expect(status).to   eql(303) }
      it { expect(location).to eql('/unicorns') }
      it { expect(body).to     be_empty }
    end

    context 'redirect with status' do
      let(:uri) { '/zebras' }

      it { expect(status).to eql(307) }
    end
  end

  describe 'logical redirections' do
    let(:method) { 'GET' }

    context 'block' do
      let(:uri) { "/horses/#{id}" }

      it { expect(status).to   eql(303) }
      it { expect(location).to eql("/horses/#{id}/GET") }
    end

    context 'block with url expanding' do
      let(:uri) { "/ponies/#{id}" }

      it { expect(status).to   eql(303) }
      it { expect(location).to eql("/unicorns/#{id}") }
    end

    context 'pattern' do
      let(:uri) { "/birds/#{id}" }

      it { expect(status).to   eql(303) }
      it { expect(location).to eql("/dragons/#{id}") }
    end

    context 'uri template' do
      let(:uri) { "/goats/#{id}" }

      it { expect(location).to eql("/unicorns/#{id}") }
    end

    context 'name' do
      let(:uri) { "/zebras/#{id}" }

      it { expect(status).to   eql(303) }
      it { expect(location).to eql("/unicorns/#{id}") }
    end
  end

  describe 'global options' do
    let(:method) { 'GET' }

    describe 'default_redirect_status' do
      let(:uri) { '/ponies' }

      context 'when not set' do
        it '303' do
          expect(status).to eql(303)
        end
      end

      context 'when set' do
        let(:options) do
          { default_redirect_status: 302 }
        end

        it 'should be as described' do
          expect(status).to eql(302)
        end
      end
    end

    describe 'default_redirect_additional_values' do
      let(:uri) { "/birds/kiwi/#{id}" }

      context 'defaults to :ignore' do
        it 'ignores additional values' do
          expect(location).to eql("/dragons/#{id}")
        end
      end

      context 'when :append' do
        let(:options) do
          { default_redirect_additional_values: :append }
        end

        it 'appends additional values as query string' do
          expect(location).to eql("/dragons/#{id}?type=kiwi")
        end
      end
    end
  end

  describe 'redirect options' do
    let(:method) { 'GET' }

    describe 'additional_values' do
      let(:uri) { "/goats/angora/#{id}" }

      it { expect(location).to eql("/unicorns/#{id}?type=angora") }
    end
  end

end
