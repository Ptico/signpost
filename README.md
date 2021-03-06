# Signpost

Standalone router for rack

Release `0.1.0` is a technical preview. Feel free to create issues for bugs, suggestions or feature requests.

## Basic usage

```ruby
builder = Signpost::Builder.new do
  root.to('home')

  get('/users').to('users#index')
  get('/users/:id').to('users#index')
  post('/users').to('users#create')
end

App = builder.build

run App
```

## Routes

### Methods

Signpost provides API for the common HTTP methods

```ruby
Signpost::Builder.new do
  get('/somewhere').to('some#action')
  post('/somewhere').to('some#action')
  put('/somewhere').to('some#action')
  patch('/somewhere').to('some#action')
  options('/somewhere').to('some#action')
  delete('/somewhere').to('some#action')
end
```

also it has a special methods: `root` and `match`. First one will add `GET /` route named `root`. Second will match all or specified methods.

```ruby
Signpost::Builder.new do
  root.to('home#index')

  match('/blog').to('blogs')
  match('/users').to('users').via(:get, :post)
end
```

Please note that `root` will add route to the top of stack:

```ruby
Signpost::Builder.new do
  get('/').to(controller: 'One', action: 'home')

  root.to(controller: 'Two', action: 'home')
end
```

will resolve controller `Two` for root path

For namespaces `root` method will add namespaced root named route:

```ruby
Signpost::Builder.new do
  root.to(Home)

  namespace :admin do
    root.to('admin#home')
  end
end
```

will generate routes with `root` and `admin_root` names. For named routes usage see [Named Routes](#named-routes) section.

### Patterns

Signpost pattern matching powered by awesome [mustermann](https://github.com/rkh/mustermann) gem.
By default it uses sinatra-style patterns, but you can easily change the style by `:style` option:

```ruby
 # in Gemfile

gem 'mustermann-flask'

 # then

builder = Signpost::Builder.new(style: :flask) do
  post('/users/<int:id>').to('users#create')
end
```

See the full list of supported styles in [mustermann's readme](https://github.com/rkh/mustermann#pattern-types)

If you need another pattern: mustermann provides an API for custom patterns [example](https://github.com/rkh/mustermann/blob/master/mustermann-cake/lib/mustermann/cake.rb). Do not forget to share your pattern with the world ;)

### Endpoints

Basically, any rack-compatible (responds to call and returns rack result) ruby object can be an endpoint.

It may be just lambda:

```ruby
get('/').to(->(env) { [200, {}, ['Hello world!']] })

 # which is the same as

get('/').to do |env|
  [200, {}, ['Hello world!']]
end

 # also you can omit #to

get('/') do |env|
  [200, {}, ['Hello world!']]
end
```

or any class which responds to `#call`

```ruby
get('/').to(Home)
get('/').to('Home') # Will try to resolve constant after
```

### Endpoint format

In case of string like `admin/users#index` resolver will try to get `Admin::Users::Index` class.
If it doesn't exists, `Admin::Users` will be expected as an endpoint, which will dispatch corresponding action itself.

```ruby
class Admin::Users
  def self.call(env)
    new.call(env['router.params']['action'])
  end

  def index
    [200, {}, []]
  end
end

 # index action will be called this way:

get('/admin/users').to('admin/users#index')
```

By default, resolver looks for exact controller name. You can change naming pattern by `:controller_format` option:

```ruby
builder = Signpost::Builder.new(controller_format: '%{name}Controller') do
  root.to('pages#index') # PagesController
end
```

also, you can use `plural_name` and `singular_name`

```ruby
builder = Signpost::Builder.new(controller_format: '%{plural_name}Controller')
builder.root.to('page#index') # PagesController

builder = Signpost::Builder.new(controller_format: 'Controllers::%{singular_name}')
builder.root.to('pages#index') # Controllers::Page
```

Hash is also a valid format for declaring endpoint:

```ruby
builder.get('/users').to(controller: Users, action: 'index')
builder.get('/users').to(controller: 'Users', action: 'index')

 # for single-class actions

builder.get('/users').to(controller: Users, action: Index)
builder.get('/users').to(controller: Users::Index)
builder.get('/users').to(Users::Index)
```

## Constraints

### Path constraints

```ruby
get('/users/:id').to('users#show').capture(/\d+/)
get('/users/:id').to('users#show').capture(:digit)
```

Available POSIX character classes are: `:alnum`, `:alpha`, `:blank`, `:cntrl`, `:digit`, `:graph`, `:lower`, `:print`, `:punct`, `:space`, `:upper`, `:xdigit`, `:word` and `:ascii`


If you need more:

```ruby
get('/unicorns/:id_or_name').to('unicorns#show').capture([/\d+/, :word])

get('/unicorns/:type/:id').to('unicorns#show').capture(id: /\d+/, type: :word)
get('/images/:id.:ext').to('images').capture(id: /\d+/, ext: ['png', 'jpg'])
```

### Exclude constraints

```ruby
delete('/users/:name').to('users#destroy').except('/users/admin')

get('/pages/*slug/edit').to('pages#edit').except('/pages/system/*/edit')
```

### Logical constraints

```ruby
get('/stats').to(Dashboard).constraint(->(env) { env['RACK_ENV'] == 'development' })
get('/admin').to('admin#index').constraint(IpRestrictor.new) # Objects with #call method allowed too

get('/stats').to(Dashboard).constraints(
  ->(env) { env['RACK_ENV'] == 'development' },
  ->(env) { env['admin'] }
)
```

## Named routes

Named routes can be used in path helpers:

```ruby
builder = Signpost::Builder.new do
  root.to('Home')

  get('/users/:id').to('users#show').as(:show_users)

  namespace :users do
    post('/types').to('types#create').as(:create, :type)
  end
end

router = builder.build

router.expand(:root) # '/'
router.expand(:show_users, id: 2) # /users/2
router.expand(:create_users_type) # /users/types
```

## Nested routes

Routes can be grouped into subroute for better readability and performance

```ruby
Signpost::Builder.new do
  within('/users') do
    root.to(controller: 'users', action: 'index')

    patch(':id').to(controller: 'users', action: 'update') # /users/:id
    get('inventory').to('users#inventory')  # /users/inventory
    get('/inventory').to('users#inventory') # the same, leading slash will be ignored

    within('/types') do
      post('/').to('users/types#create') # /users/types
      patch(':id').to('users/types#update') # /users/2
    end
  end
end
```

note, that `within` does not introduce class or name namespace. So `root` inside `within` block will not add any named route.
Also, for sinatra-style, only trailing slash will match (this is the subject to fix).

## Namespaces

Namespace is basically just `within` which adds class and named route namespace:

```ruby
namespace :admin do
  root.to('dashboard') # :admin_root name, /admin path and Admin::Dashboard controller

  namespace :types do
    get('edit').to(action: 'edit').as(:edit) # :admin_types_edit name, Admin::Types controller and /admin/types/edit path

    get(':id/properties').to(action: 'show').as(:show, :properties) # :show_admin_types_properties name
  end
end
```

## Resources

Will be introduced in `0.2.0`

## Redirects

Simple redirects:

```ruby
Signpost::Builder.new do
  redirect('/horses').to('/unicorns').permanent
  redirect('/ponies').to('/unicorns')
  redirect('/zebras').to('/unicorns').with_status(307)
end
```

by default, redirect uses `303` code. It can be changed in [options](#options)


Pattern to pattern redirects are also allowed:

```ruby
redirect('/birds/:id').to('/dragons/:id')
redirect('/goats/:id').to('/unicorns/{id}s')
```


If source has more parameters than target, additional values will be ignored. To change this, you can use `:append` directive:

```ruby
redirect('/goats/:type/:id').to('/unicorns/:id', :append)
```

or set option `:default_redirect_additional_values` to `:append`. All additional values will be applied as query string params: `/goats/angora/2` will be redirected to `/unicorns/2?type=angora`.


If target route have name, it's easy to reuse the pattern:

```ruby
get('/unicorns/:id').to('unicorns#show').as(:show_unicorn)
redirect('/zebras/:id').to(:show_unicorn)
```


For more complex redirects you can use block:

```ruby
redirect('/horses/:id') do
  "/horses/#{params['id']}/#{env['REQUEST_METHOD']}"
end
redirect('/ponies/:type') do
  expand(:show_unicorn, params['type'].downcase)
end
```

## Options

| Name | Default | Values | Description |
|------|---------|--------|-------------|
| `:style` | `:sinatra` | See [mustermann's readme](https://github.com/rkh/mustermann#pattern-types) | URL pattern style |
| `:controller_format` | `'%{name}'` | | Format for controller name. See [Endpoint format](#endpoint-format) section |
| `:params_key` | `'router.params'` | | Key used for rack environment to conduct matched values, controller name and action name |
| `:rack_params` | `false` | true, false | To be compatible with `Rack::Request` params, router params can be merged into `rack.request.query_hash`. This option will turn on this behaviour |
| `:default_redirect_status` | `303` | Any `3xx` code | HTTP Status wich will be used by `redirect` when not specified |

For `:default_redirect_additional_values` see [Redirects](#redirects)
