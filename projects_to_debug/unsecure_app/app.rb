require 'sinatra/base'
require "sinatra/reloader"

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    return erb(:index)
  end

  post '/hello' do
    @name = params[:name]
    if @name =~ /[^\w\s]/
      status 400
      return ""
    end
    return erb(:hello)
  end
end
