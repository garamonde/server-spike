require 'garamonde'
require 'sinatra/base'
require 'json'

class Garamonde::API < Sinatra::Base

  get '/' do
    'Hi'
  end

  ## Users

  def users
    $users ||= Garamonde::Users.new
  end

  def admins
    $admins ||= Garamonde::Users::Admins.new
  end

  def storylines
    $storylines ||= Garamonde::Storylines.new
  end

  post '/users' do
    user = users.register(
      email: params[:user][:email]
    )

    if user
      {
        status: user.status,
        user: {
          email: user.email,
          auth_code: user.auth_code
        }
      }.to_json
    else
      status 422
      {
        status: "missing email"
      }.to_json
    end
  end

  post '/users/sessions' do
    session = users.sign_in(
      auth_code: params[:auth_code]
    )

    if session.successful?
      {
        status: session.status,
        session: {
          token: session.token
        }
      }.to_json
    else
      status 403 
      {
        status: session.status
      }.to_json
    end
  end

  delete '/users/sessions/:code' do
    session = users.sign_out(
      auth_code: params[:code]
    )

    unless session.successful?
      status 404
    end
    {
      status: session.status
    }.to_json
  end

  ## Storylines

  def resource(type, resource, *additional)
    elements  = [
      "/#{type}s",
      resource.id,
    ] + additional

    url elements.join("/")
  end

  def authenticate(what = users, &blk)
    what.authenticate(token: params[:token]) do |session|
      if session.successful?
        yield session
      else
        status 403
        {
          status: session.status
        }.to_json
      end
    end
  end

  def storyline_json(storyline)
    {
      status: storyline.status,
      links: {
        this: resource(:storyline, storyline),
        updates: resource(:storyline, storyline, :updates) 
      },
      storyline: {
        id: storyline.id
      }
    }
  end

  post '/storylines' do
    authenticate do |session|
      storylines.start(session: session) do |storyline|
        storyline_json(storyline).to_json
      end
    end
  end

  get '/storylines' do
    authenticate do |session|
      storyline_entries = []
      storylines.each(session: session) do |storyline|
        storyline_entries << storyline_json(storyline)
      end
      {
        storylines: storyline_entries
      }.to_json
    end
  end

  get '/storylines/:id' do
    authenticate do |session|
      storylines.lookup(session: session, id: params[:id]) do |storyline|
        {
          links: {
            this: resource(:storyline, storyline),
            updates: resource(:storyline, storyline, :updates)
          },
          storyline: {
          
          }
        }.to_json
      end
    end
  end

  get '/storylines/:id/updates' do
    authenticate do |session|
      storylines.lookup(session: session, id: params[:id]) do |storyline|
        {
          links: {
            this: resource(:storyline, storyline),
            updates: resource(:storyline, storyline, :updates)
          },
          storyline: {
            updates: storyline.updates
          }
        }.to_json
      end
    end
  end

  post '/storylines/:id/updates' do
    authenticate(admins) do |session|
      storylines.add_updates(id: params[:id], updates: params[:updates])
      { status: "updates added" }.to_json
    end
  end

end
