require 'sinatra/base'

class Garamonde::Site < Sinatra::Base

  get '/' do
    haml :index
  end

end
