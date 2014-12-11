class Signpost
  class Middleware
    attr_reader :middleware

    attr_reader :args

    attr_reader :block

  private

    def initialize(middleware, args, block)
      @middleware = middleware
      @args  = args
      @block = block
    end
  end
end
