class Signpost
  module Endpoint
    class Redirect

      class Context

        attr_reader :params, :env

        def expand(path, data={})
          @router.expand(path, data)
        end

      private

        def initialize(router, env, params)
          @router = router
          @env    = env
          @params = params
        end
      end

      attr_reader :status

      CODES = {
        permanent: 301,
        temporary: 303
      }.freeze

      def call(env)
        [status, headers(env), body]
      end

    private

      def initialize(to, router, status=303)
        @to     = to
        @status = status.is_a?(Fixnum) ? status : CODES[status.to_sym]
        @router = router
        @params_key = router.params_key
      end

      def headers(env)
        { 'Location' => to(env) }
      end

      def to(env)
        params = env[@params_key]

        case @to
          when Proc
            Context.new(@router, env, params).instance_exec(&@to)
          when Symbol
            params = @router.expand(@to, params)
          else
            @to.expand(params)
        end
      end

      def body
        []
      end

    end
  end
end
