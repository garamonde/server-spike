ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'rspec'
require 'capybara/rspec'
require 'rack/test'
require 'json'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include( Module.new do

    def response_json
      JSON.parse(last_response.body)
    end

    def response_data
      ostructify response_json
    end

    def ostructify(data)
      case data
      when Hash
        OpenStruct.new.tap do |os|
          data.each do |key, value|
            os[key] = ostructify value
          end
        end
      when Array
        data.map{|each| ostructify each }
      else
        data
      end
    end
  
  end )

end

module RackHelpers

  def app
    Garamonde::App
  end

  def register(user)
    post "/users", user: user
  end

  def sign_in(code)
    post "/users/sessions", auth_code: code
  end

  def sign_out(code)
    delete "/users/sessions/#{code}"
  end

end
