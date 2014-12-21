class Signpost
  class Route
    class Nested
      attr_reader :subpath

      def match(path, env)
        return unless path.start_with?(subpath)

        @router.call(env)
      end

    private

      def initialize(subpath, router)
        @subpath = subpath
        @router  = router
      end
    end
  end
end
