class Signpost
  module Endpoint
    class Dynamic
      def call(env)
        controller, action = env[@params_key].values_at('controller', 'action')

        resolver = Resolver.new({
          controller: @spec[:controller] || controller,
          action: @spec[:action] || action
        }, @namespace, @options[:controller_format]).resolve

        resolver.endpoint.call(env)
      end

    private

      def initialize(namespace, options, spec={})
        @namespace = namespace
        @options = options
        @spec = spec
        @params_key = options[:params_key]
      end
    end
  end
end
