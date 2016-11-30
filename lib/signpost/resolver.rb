class Signpost
  class Resolver

    ##
    # Class: result of resolving
    #
    # Here is `#endpoint` is an endpoint class and `#params` is a hash
    # with controller and action names
    #
    Result = Struct.new(:endpoint, :params)

    ##
    # Class: resolver error
    #
    # When raises, it means that controller or action
    # can't be resolved with given params
    #
    UnresolvedError = Class.new(StandardError)

    ##
    # Resolve endpoint and params
    #
    # Returns: {Signpost::Resolver::Result}
    #
    def resolve
      params   = get_params(*get_controller_and_action)
      endpoint = params[:action].respond_to?(:call) ? params[:action] : params[:controller]

      Result.new(endpoint, params)
    end

  private

    ##
    # Constructor:
    #
    # Params:
    # - spec {String|Hash|Class|Proc} user defined endpoint specification
    # - namespace {Class|Module} namespace
    # - format {String} controller naming format
    #
    def initialize(spec, namespace, format)
      @spec      = spec
      @namespace = namespace
      @format    = format || '%{name}'
    end

    ##
    # Private: get controller and action from spec
    #
    # Example:
    #
    #     'users#show' gives 'users', 'show'
    #     Users::Show gives nil, Users::Show
    #     {controller: Users, action: 'show'} gives Users, 'show'
    #
    def get_controller_and_action
      if @spec.kind_of?(String) && @spec.include?('#')
        @spec.split('#')
      elsif @spec.kind_of?(Hash)
        [@spec[:controller], @spec[:action]]
      else
        [nil, @spec]
      end
    end

    def get_params(cnt_name, act_name)
      controller = cnt_name.kind_of?(String) ? get_controller(cnt_name) : cnt_name

      action = act_name.kind_of?(String) ? get_action(controller || @namespace || Object, act_name) : act_name

      controller = @namespace if controller.nil? && action.is_a?(String) # TODO - remove?

      { controller: controller, action: action }
    end

    def controller_name(str)
      names = {
        name:          Inflecto.camelize(str),
        plural_name:   Inflecto.camelize(Inflecto.pluralize(str)),
        singular_name: Inflecto.camelize(Inflecto.singularize(str))
      }

      (@format || '%{name}') % names
    end

    def get_controller(str)
      const((@namespace || Object), controller_name(str)) || fail(UnresolvedError)
    end

    def get_action(controller, action)
      camelized = Inflecto.camelize(action)
      const(controller, camelized) || action
    end

    ##
    # Get constant from camelized string, avoiding upper-level
    # defined constants with the same name
    #
    # Params:
    # - parent {constant} namespace for lookup
    # - child  {String}   camelized string (example: Foo::Bar)
    #
    def const(parent, child)
      parts = child.split('::')

      if parts.first == '' # omit namespace if ::Foo
        parent = Object
        parts.shift
      end

      parts.inject(parent) do |constant, name|
        if constant.constants.include?(name.to_sym)
          constant.const_get(name)
        else
          return nil
        end
      end
    end

  end
end
