require 'set'
require 'mustermann'
require 'inflecto'

class Signpost
  SUPPORTED_METHODS = %w(GET POST PUT PATCH OPTIONS DELETE).map(&:freeze).to_set.freeze
end

require 'signpost/version'
require 'signpost/route/simple'
require 'signpost/route/nested'
require 'signpost/router'

require 'signpost/middleware'

require 'signpost/endpoint/resolver'
require 'signpost/endpoint/dynamic'
require 'signpost/endpoint/builder'

require 'signpost/builder/simple'
require 'signpost/builder/simple/path'
require 'signpost/builder/nested'
require 'signpost/builder'
