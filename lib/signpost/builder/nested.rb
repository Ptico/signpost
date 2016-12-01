class Signpost
  class Builder
    class Nested < self

      def build
        Router.new(@signs, @middlewares, @options)
      end

    private

      def root_name
        nil
      end

    end
  end
end
