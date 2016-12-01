class ActionController
  def self.call(env)
    params = env['router.params']

    body = new(params).send(params['action'])
    [200, {}, [body]]
  end

  attr_reader :params

  def initialize(params)
    @params = params
  end
end
