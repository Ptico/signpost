class Signpost
  class Router
    RACK_REQUEST_METHOD = 'REQUEST_METHOD'.freeze
    RACK_REQUEST_PATH   = 'PATH_INFO'.freeze
    RACK_QUERY_HASH     = 'rack.request.query_hash'.freeze

    def call(env)
      @routes[env[RACK_REQUEST_METHOD]].each do |route|
        if params = route.match(env[RACK_REQUEST_PATH], env)
          if @options[:rack_params]
            env[RACK_QUERY_HASH] = env[RACK_QUERY_HASH] ? env[RACK_QUERY_HASH].merge(params) : params
          end

          env[@options[:params_key]] = params

          return route.endpoint.call(env)
        end
      end

      [404, {}, ['']]
    end

  private

    def initialize(builders, options)
      @routes = SUPPORTED_METHODS.each_with_object({}) { |m, h| h[m] = [] }.freeze
      @named_routes = {}
      @options = options

      builders.each do |builder|
        route = builder.build
        @named_routes[route.name] = route if route.name

        builder.http_methods.each do |method|
          @routes[method] << route
        end
      end
    end
  end
end
