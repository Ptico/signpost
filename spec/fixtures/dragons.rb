class Dragons < ActionController
  module Types
    class Create
      def self.call(env)
        "dragon-type|create|#{env['router.params']['id']}"
      end
    end
  end

  def index
    'dragons|index'
  end

  def show
    "dragons|show|#{params['id']}"
  end

  def create
    'dragons|create'
  end

  def edit
    "dragons|edit|#{params['id']}"
  end

  def destroy
    "dragons|destroy|#{params['id']}"
  end
end
