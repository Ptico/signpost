class Signpost
  class Route
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
    def match(path)
      return nil unless data = matcher.match(path)
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

    def initialize(matcher, endpoint, params={}, name=nil)
      @matcher  = matcher
      @endpoint = endpoint
      @params   = params.each_with_object({}) { |t, h| h[t[0].to_s] = t[1] }.freeze
      @name     = name ? name.to_sym : nil

      freeze
    end
  end
end
