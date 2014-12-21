class Signpost
  class Route
    class Simple
      ##
      # Route matcher/expander
      #
      # Returns: {Mustermann}
      #
      attr_reader :matcher

      ##
      # Rack-compatible endpoint
      #
      # Returns: {Proc|Object}
      #
      attr_reader :endpoint

      ##
      # Specific route params
      #
      # Returns: {Hash}
      #
      attr_reader :params

      ##
      # Environment constraints
      #
      # Returns: {Array}
      #
      attr_reader :constraints

      ##
      # Route name
      #
      # Returns: {Symbol}
      #
      attr_reader :name

      ##
      # Match path and return matched data or nil if path doesn't match
      #
      # Params:
      # - path {String} uri path
      #
      # Example:
      #
      #     route.match('/users/42') #=> { 'controller' => 'Users', 'action' => 'Show', 'id' => '42' }
      #     route.match('/foo/bar')  #=> nil
      #
      # Returns: {Hash|NilClass}
      #
      def match(path, env)
        return unless data = matcher.match(path)

        return unless constraints.all? { |c| c.call(env) }

        params.merge(Hash[data.names.zip(data.captures)])
      end

      ##
      # Generate a string from path pattern
      #
      # Params:
      # - data {Hash} key-values for expanding
      #
      # Example:
      #
      #     route.expand({ id: 42 }) #=> '/users/42'
      #
      # Returns: {String}
      #
      def expand(data={})
        matcher.expand(data)
      end

    private

      def initialize(matcher, endpoint, params={}, constraints=[], name=nil)
        @matcher     = matcher
        @endpoint    = endpoint
        @params      = params.each_with_object({}) { |(k, v), h| h[k.to_s] = v }.freeze
        @constraints = constraints
        @name        = name ? name.to_sym : nil

        freeze
      end
    end
  end
end
