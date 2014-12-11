class ActionController
  def self.call(env)
    params = env['router.params']

    new(params).send(params['action'])
  end

  attr_reader :params

  def initialize(params)
    @params = params
  end
end
