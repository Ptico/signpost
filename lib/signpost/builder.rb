class Signpost
  class Builder
    DEFAULT_OPTIONS = {
      params_key: 'router.params',
      default_redirect_status: 303,
      default_redirect_additional_values: :ignore,
      style: :sinatra,
      rack_params: false
    }.freeze
    SUBPATH_REG = /^\//.freeze

    ##
    # Define root route
    #
    # Root route will always be in top of routes
    # Also this is named route with name `root`
    #
    # Example:
    #
    #    root.to(HomeController)
    #
    def root(&block)
      builder = Sign::Flat::Path::GET.new(absolute('/'), @options, &block)
      @signs.unshift(builder)
      builder.as(root_name)
    end

    ##
    # Define route which accepts GET request for the given pattern
    #
    # Params:
    # - path {String|RegExp} pattern of the request path which should be matched
    #
    # Yields: the Rack compatible block
    #
    # Example:
    #
    #     # Most usual case: with controller and action. Will resolve Controller#action or Controller::Action
    #     get('/users').to(controller: 'Users', action: 'index')
    #     get('/users').to(controller: UsersController, action: 'index')
    #     get('/users').to('users#index')
    #
    #     # Single action controller (responds to .call)
    #     get('/').to(HomeController)
    #
    #     # Sinatra-style block action
    #     get('/echo').to do |env|
    #       [200, {}, [env['SERVER_NAME']]]
    #     end
    #     get('/echo') do |env|
    #       [200, {}, [env['SERVER_NAME']]]
    #     end
    #
    #     # Path params
    #     get('/users/:id').to('users#show')
    #
    #     # Params constraints
    #     get('/users/:id').to('users#show').capture(:digit)
    #     get('/users/:id.:ext').to('pages#show').capture({ id: /\d+/, ext: ['json', 'html'] })
    #
    #     # Exclude pattern
    #     get('/pages/*slug/edit').to('pages#edit').except('/pages/system/*/edit')
    #
    #     # Default params
    #     get('/:controller/:action/:id').params(id: 1)
    #
    def get(path, &block)
      builder = Sign::Flat::Path::GET.new(absolute(path), @options, &block)
      @signs << builder
      builder
    end

    ##
    # Define route which accepts POST request for the given pattern
    #
    # Params:
    # - path {String|RegExp} pattern of the request path which should be matched
    #
    # Yields: the Rack compatible block
    #
    # Example:
    #
    #     # Most usual case: with controller and action. Will resolve Controller#action or Controller::Action
    #     post('/users').to(controller: 'Users', action: 'create')
    #     post('/users').to(controller: UsersController, action: 'create')
    #     post('/users').to('users#create')
    #
    #     # Single action controller (responds to .call)
    #     post('/search').to(SearchController)
    #
    #     # Sinatra-style block action
    #     post('/echo').to do |env|
    #       [201, {}, [env['SERVER_NAME']]]
    #     end
    #     post('/echo') do |env|
    #       [201, {}, [env['SERVER_NAME']]]
    #     end
    #
    #     # Path params
    #     post('/users/:id').to('users#update')
    #
    #     # Params constraints
    #     post('/users/:id').to('users#update').capture(:digit)
    #     post('/users/:id.:ext').to('pages#show').capture({ id: /\d+/, ext: ['json', 'html'] })
    #
    #     # Exclude pattern
    #     post('/pages/*slug/update').to('pages#update').except('/pages/system/*/update')
    #
    #     # Default params
    #     post('/:controller/:action/:id').params(id: 1)
    #
    def post(path, &block)
      builder = Sign::Flat::Path::POST.new(absolute(path), @options, &block)
      @signs << builder
      builder
    end

    ##
    # Define route which accepts PUT request for the given pattern
    #
    # Params:
    # - path {String|RegExp} pattern of the request path which should be matched
    #
    # Yields: the Rack compatible block
    #
    # Example:
    #
    #     # Most usual case: with controller and action. Will resolve Controller#action or Controller::Action
    #     put('/users').to(controller: 'Users', action: 'create')
    #     put('/users').to(controller: UsersController, action: 'create')
    #     put('/users').to('users#create')
    #
    #     # Single action controller (responds to .call)
    #     put('/search').to(SearchController)
    #
    #     # Sinatra-style block action
    #     put('/echo').to do |env|
    #       [201, {}, [env['SERVER_NAME']]]
    #     end
    #     put('/echo') do |env|
    #       [201, {}, [env['SERVER_NAME']]]
    #     end
    #
    #     # Path params
    #     put('/users/:id').to('users#update')
    #
    #     # Params constraints
    #     put('/users/:id').to('users#update').capture(:digit)
    #     put('/users/:id.:ext').to('pages#show').capture({ id: /\d+/, ext: ['json', 'html'] })
    #
    #     # Exclude pattern
    #     put('/pages/*slug/update').to('pages#update').except('/pages/system/*/update')
    #
    #     # Default params
    #     put('/:controller/:action/:id').params(id: 1)
    #
    def put(path, &block)
      builder = Sign::Flat::Path::PUT.new(absolute(path), @options, &block)
      @signs << builder
      builder
    end

    ##
    # Define route which accepts PATCH request for the given pattern
    #
    # Params:
    # - path {String|RegExp} pattern of the request path which should be matched
    #
    # Yields: the Rack compatible block
    #
    # Example:
    #
    #     # Most usual case: with controller and action. Will resolve Controller#action or Controller::Action
    #     patch('/users/:id').to(controller: 'Users', action: 'update')
    #     patch('/users/:id').to(controller: UsersController, action: 'update')
    #     patch('/users/:id').to('users#update')
    #
    #     # Single action controller (responds to .call)
    #     patch('/users/:id').to(UsersUpdateController)
    #
    #     # Sinatra-style block action
    #     patch('/echo').to do |env|
    #       [201, {}, [env['SERVER_NAME']]]
    #     end
    #     patch('/echo') do |env|
    #       [201, {}, [env['SERVER_NAME']]]
    #     end
    #
    #     # Params constraints
    #     patch('/users/:id').to('users#update').capture(:digit)
    #     patch('/users/:id.:ext').to('pages#show').capture({ id: /\d+/, ext: ['json', 'html'] })
    #
    #     # Exclude pattern
    #     patch('/pages/*slug/update').to('pages#update').except('/pages/system/*/update')
    #
    #     # Default params
    #     patch('/:controller/:action/:id').params(id: 1)
    #
    def patch(path, &block)
      builder = Sign::Flat::Path::PATCH.new(absolute(path), @options, &block)
      @signs << builder
      builder
    end

    ##
    # Define route which accepts OPTIONS request for the given pattern
    #
    # Params:
    # - path {String|RegExp} pattern of the request path which should be matched
    #
    # Yields: the Rack compatible block
    #
    # Example:
    #
    #     # Most usual case: with controller and action. Will resolve Controller#action or Controller::Action
    #     options('/users').to(controller: 'Users', action: 'usage')
    #     options('/users').to(controller: UsersController, action: 'usage')
    #     options('/users').to('users#usage')
    #
    #     # Single action controller (responds to .call)
    #     options('/').to(HomeController)
    #
    #     # Sinatra-style block action
    #     options('/echo').to do |env|
    #       [200, {}, [env['SERVER_NAME']]]
    #     end
    #     options('/echo') do |env|
    #       [200, {}, [env['SERVER_NAME']]]
    #     end
    #
    #     # Path params
    #     options('/users/:id').to('users#show')
    #
    #     # Params constraints
    #     options('/users/:id').to('users#usage').capture(:digit)
    #     options('/users/:id.:ext').to('pages#usage').capture({ id: /\d+/, ext: ['json', 'html'] })
    #
    #     # Exclude pattern
    #     options('/pages/*slug/usage').to('pages#usage').except('/pages/private/*/usage')
    #
    #     # Default params
    #     options('/:controller/:action/:id').params(id: 1)
    #
    def options(path, &block)
      builder = Sign::Flat::Path::OPTIONS.new(absolute(path), @options, &block)
      @signs << builder
      builder
    end

    ##
    # Define route which accepts PATCH request for the given pattern
    #
    # Params:
    # - path {String|RegExp} pattern of the request path which should be matched
    #
    # Yields: the Rack compatible block
    #
    # Example:
    #
    #     # Most usual case: with controller and action. Will resolve Controller#action or Controller::Action
    #     delete('/users/:id').to(controller: 'Users', action: 'destroy')
    #     delete('/users/:id').to(controller: UsersController, action: 'destroy')
    #     delete('/users/:id').to('users#destroy')
    #
    #     # Single action controller (responds to .call)
    #     delete('/users/:id').to(UsersDestroyController)
    #
    #     # Sinatra-style block action
    #     delete('/echo').to do |env|
    #       [201, {}, [env['SERVER_NAME']]]
    #     end
    #     delete('/echo') do |env|
    #       [201, {}, [env['SERVER_NAME']]]
    #     end
    #
    #     # Params constraints
    #     delete('/users/:id').to('users#destroy').capture(:digit)
    #     delete('/users/:id.:ext').to('pages#destroy').capture({ id: /\d+/, ext: ['json', 'html'] })
    #
    #     # Exclude pattern
    #     delete('/pages/*slug/destroy').to('pages#destroy').except('/pages/system/*/destroy')
    #
    #     # Default params
    #     delete('/:controller/:action/:id').params(id: 1)
    #
    def delete(path, &block)
      builder = Sign::Flat::Path::DELETE.new(absolute(path), @options, &block)
      @signs << builder
      builder
    end

    ##
    # Define route which accepts any type (or specified list) of request for the given pattern
    #
    # Params:
    # - path {String|RegExp} pattern of the request path which should be matched
    #
    # Yields: the Rack compatible block
    #
    # Example:
    #
    #     # Most usual case: with controller and action. Will resolve Controller#action or Controller::Action
    #     match('/users').to(controller: 'Users', action: 'index')
    #     match('/users').to(controller: UsersController, action: 'index')
    #     match('/users').to('users#index')
    #
    #     # Specify types of requests
    #     match('/users').to('users#create').via(:post, :put)
    #
    #     # Single action controller (responds to .call)
    #     match('/').to(HomeController)
    #
    #     # Sinatra-style block action
    #     match('/echo').to do |env|
    #       [200, {}, [env['SERVER_NAME']]]
    #     end
    #     match('/echo') do |env|
    #       [200, {}, [env['SERVER_NAME']]]
    #     end
    #
    #     # Path params
    #     match('/users/:id').to('users#show')
    #
    #     # Params constraints
    #     match('/users/:id').to('users#show').capture(:digit)
    #     match('/users/:id.:ext').to('pages#show').capture({ id: /\d+/, ext: ['json', 'html'] })
    #
    #     # Exclude pattern
    #     match('/pages/*slug/edit').to('pages#edit').except('/pages/system/*/edit')
    #
    #     # Default params
    #     match('/:controller/:action/:id').params(id: 1)
    #
    def match(path, &block)
      builder = Sign::Flat::Path::Any.new(absolute(path), @options, &block)
      @signs << builder
      builder
    end

    ##
    # Define redirection route
    #
    # Params:
    # - path {String|RegExp} pattern of the request path which should be matched
    #
    def redirect(path, &block)
      builder = Sign::Flat::Redirect.new(absolute(path), @options, &block)
      @signs << builder
      builder
    end

    ##
    # Define nested routes
    #
    # Params:
    # - path {String} subpath
    #
    # Yields: routes dsl
    #
    # Example:
    #
    #     within('/admin') do
    #       get('/pages').to('Admin::Pages#index')     # /admin/pages
    #       put('/users/:id').to('admin/users#create') # /admin/users/2
    #     end
    #
    #     # Nested routes can has their own routes
    #     within('/admin') do
    #       get('/').to('admin#index')
    #
    #       within('/pages') do
    #         get('/').to('admin/pages#index')     # /admin/pages
    #         put('/:id').to('admin/pages#create') # /admin/pages/2
    #       end
    #     end
    #
    #     # You can also build a middleware stack for subroutes
    #     within('/admin') do
    #       use AuthMiddleware
    #
    #       get('/').to('admin#index')
    #     end
    #
    def within(path, &block)
      @signs << Sign::Nested.new(absolute(path), @options, &block)
    end

    ##
    # Define namespace
    #
    # Params:
    # - name {String|Symbol} namespace name
    #
    # Yields: routes dsl
    #
    # Example:
    #
    #     namespace :admin do
    #       root.to('dashboard') # :admin_root name, /admin path and Admin::Dashboard controller
    #
    #       namespace :types do
    #         get('edit').to(action: 'edit').as(:edit) # :admin_types_edit name, Admin::Types controller and /admin/types/edit path
    #
    #         get(':id/properties').to(action: 'show').as(:show, :properties) # :show_admin_types_properties name
    #       end
    #     end
    #
    def namespace(name, &block)
      options = @options.merge(namespace: [@options[:namespace], name].flatten)
      @signs << Sign::Namespace.new(absolute(name.to_s), options, &block)
    end

    ##
    # Add middleware to routes
    #
    # Params:
    # - middleware {String|Class} middleware or middleware name
    # - *args                     middleware arguments which will be used for instantiating
    #
    # Example:
    #
    #     use Rack::Errors
    #     use AuthMiddleware, 'admin', 'seCrEt'
    #
    def use(middleware, *args, &block)
      @middlewares << Middleware.new(middleware, args, block)
    end

    ##
    # Build router
    #
    # Returns: {Signpost::Router}
    #
    def build
      Router.new(@signs, @middlewares, @options, true)
    end

  private

    def initialize(options={}, &block)
      @options     = DEFAULT_OPTIONS.merge(options)
      @subroute    = options[:subroute] || '/'
      @signs       = []
      @middlewares = []

      instance_eval(&block) if block_given?
    end

    def absolute(path)
      File.join(@subroute, path.gsub(SUBPATH_REG, ''))
    end

    def root_name
      'root'
    end

  end
end
