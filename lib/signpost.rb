require 'set'
require 'mustermann'
require 'inflecto'

class Signpost
  SUPPORTED_METHODS = %w(GET POST PUT PATCH OPTIONS DELETE).map(&:freeze).to_set.freeze
end

require 'signpost/version'
require 'signpost/route'
require 'signpost/router'

require 'signpost/middleware'

require 'signpost/endpoint/resolver'
require 'signpost/endpoint/dynamic'
require 'signpost/endpoint/builder'

require 'signpost/builder/plain'
require 'signpost/builder/plain/path'
require 'signpost/builder'
