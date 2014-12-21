class Unicorns < ActionController
  def index
    'unicorns|index'
  end

  def show
    "unicorns|show|#{params['id']}"
  end

  def create
    'unicorns|create'
  end

  def edit
    "unicorns|edit|#{params['id']}"
  end

  def destroy
    "unicorns|destroy|#{params['id']}"
  end
end
