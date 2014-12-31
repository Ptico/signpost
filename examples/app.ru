require 'signpost'

builder = Signpost::Builder.new do
  root.to('home')

  get('/unicorns').to('unicorns#index')
  get('/unicorns/:id').to('unicorns#show')
end

class Home
  def self.call(env)
    [200, { 'Content-Type' => 'text/html' }, ['<h1>Hello World</h1>']]
  end
end

class Unicorns
  def self.call(env)
    params = env['router.params']

    new(params).send(params['action'])
  end

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def index
    [200, { 'Content-Type' => 'text/html' }, ['<h1>Magic!</h1>']]
  end

  def show
    [200, { 'Content-Type' => 'text/html' }, ["Unicorn id: #{params['id']}"]]
  end
end

router = builder.build

run(router)
