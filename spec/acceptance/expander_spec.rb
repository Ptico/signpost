describe 'Named routes' do
  let(:builder) do
    Signpost::Builder.new do
      root.to('unicorns#index')

      get('/unicorns/:id').to('unicorns#show').as(:show_unicorns)
    end
  end

  let(:router) { builder.build }

  context 'root path' do
    let(:result) { router.expand(:root) }

    it { expect(result).to eql('/') }
  end

  context 'with params' do
    let(:result) { router.expand(:show_unicorns, { id: 2 }) }

    it { expect(result).to eql('/unicorns/2') }
  end
end
