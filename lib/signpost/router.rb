class Signpost
  class Router
    RACK_REQUEST_METHOD = 'REQUEST_METHOD'.freeze
    RACK_REQUEST_PATH   = 'PATH_INFO'.freeze
    RACK_QUERY_HASH     = 'rack.request.query_hash'.freeze

    attr_reader :routes

    attr_reader :named_routes

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

            env[@options[:params_key]] = params

            return route.endpoint.call(env)
          else
            return params
        end
      end

      not_found unless @options[:nested]
    end

  private

    def initialize(builders, options)
      @routes = SUPPORTED_METHODS.each_with_object({}) { |m, h| h[m] = [] }.freeze
      @named_routes = {}
      @options = options

      builders.each do |builder|
        builder.expose(@routes, @named_routes)
      end
    end

    def not_found
      [404, {}, ['']]
    end
  end
end
