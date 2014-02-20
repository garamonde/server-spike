require 'garamonde'
require 'sinatra/base'

class Garamonde::App < Sinatra::Base

  get '/' do
    'Hi'
  end

  ## Users

  def users
    $users ||= Garamonde::Users.new
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

  post '/storylines' do
    {
      links: {
        this: "/storylines/123",
        updates: "/storylines/123/updates"
      },
      storyline: {

      }
    }.to_json
  end

  get '/storylines/:id' do
    {
      links: {
        this: "/storylines/123",
        updates: "/storylines/123/updates"
      },
      storyline: {
      
      }
    }.to_json
  end

  get '/storylines/:id/updates' do
    {
      links: {
        this: "/storylines/123",
        updates: "/storylines/123/updates"
      },
      storyline: {
        updates: [

        ]
      }
    }.to_json
  end

end
