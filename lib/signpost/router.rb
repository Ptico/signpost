class Signpost
  class Router
    RACK_REQUEST_METHOD = 'REQUEST_METHOD'.freeze
    RACK_REQUEST_PATH   = 'PATH_INFO'.freeze
    RACK_QUERY_HASH     = 'rack.request.query_hash'.freeze

    attr_reader :routes

    attr_reader :named_routes

    attr_reader :params_key

    def call(env)
      @routes[env[RACK_REQUEST_METHOD]].each do |route|
        params = route.match(env[RACK_REQUEST_PATH], env)

        case params
          when nil
            next
          when Hash
            if @options[:rack_params]
              env[RACK_QUERY_HASH] = env[RACK_QUERY_HASH] ? env[RACK_QUERY_HASH].merge(params) : params
            end

            env[params_key] = params
            result = to_app(route.endpoint).call(env)

            if result[1] && result[1]['X-Cascade'] == 'pass'
              next
            else
              return result
            end
          else
            return params
        end
      end

      default_action
    end

    def expand(name, data={})
      @named_routes[name].expand(data)
    end

  private

    def initialize(builders, middlewares, options, root=false)
      @routes = SUPPORTED_METHODS.each_with_object({}) { |m, h| h[m] = [] }.freeze
      @middlewares = middlewares
      @named_routes = {}
      @options = options
      @root    = root

      @params_key = options[:params_key]

      builders.each do |builder|
        builder.expose(self, @routes, @named_routes)
      end
    end

    def to_app(endpoint)
      @middlewares.reverse_each.inject(endpoint) { |app, m| m.middleware.new(app, *m.args, &m.block) }
    end

    def default_action
      @root ? [404, {}, ['']] : nil
    end
  end
end
