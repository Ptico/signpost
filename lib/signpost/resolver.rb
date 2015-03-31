class Signpost
  class Resolver

    def resolve

    end

  private

    def initialize(spec, namespace, format)
      @spec      = spec
      @namespace = Array(namespace).join('/')
      @format    = format || '%{name}'
    end
  end
end
