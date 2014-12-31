class Signpost
  module Endpoint
    class Action

      class Context

        attr_reader :params, :env, :headers

        def body(text)
          @body = [text]
        end

        def status(code)
          @status = code.to_i
        end

        def expand(path, data={})
          @router.expand(path, data)
        end

        def result
          [@status, @headers, @body]
        end

      private

        def initialize(block, router, env, params)
          @router = router
          @env    = env
          @params = params

          @status  = 200
          @headers = {}
          @body    = []

          instance_eval(&block)
        end
      end

      def call(env)
        Context.new(@block, @router, env, env[@params_key]).result
      end

    private

      def initialize(block, router)
        @block      = block
        @router     = router
        @params_key = router.params_key
      end

    end
  end
end
