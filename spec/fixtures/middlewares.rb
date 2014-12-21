class AuthMiddleware < Struct.new(:app, :login, :password)
  def call(env)
    return 403 unless env['username'] == login && env['password'] == password
    app.call(env)
  end
end

class PrependMiddleware < Struct.new(:app, :string)
  def call(env)
    string + app.call(env)
  end
end
