require_relative '../spec_helper'

require 'garamonde/app/app'

describe Garamonde::App do
  include RackHelpers

  before do
    register email: "fwiffo@spathiwa.com"
    sign_in response_data.user.auth_code
    @token = response_data.session.token
  end

  def subscribe_to_storyline(args = {})
    post '/storylines', {token: @token}.merge(args)
  end

  context "/storylines" do
   
    it "should reject invalid tokens" do
      subscribe_to_storyline token: "bogoid"
      expect(last_response).not_to be_ok
    end

    it "should allow subscribing to a storyline" do
      subscribe_to_storyline
      expect(last_response).to be_ok
      expect(response_data.links.this).to be_kind_of String
      
      get response_data.links.this + "?token=#{@token}"
      expect(last_response).to be_ok
      expect(response_data.links.updates).to be_kind_of String
    end

    it "should provide storyline updates" do
      subscribe_to_storyline
      this_url = response_data.links.this
      get response_data.links.updates + "?token=#{@token}"
      expect(last_response).to be_ok
      expect(response_data.storyline.updates).to be_kind_of Array
      expect(response_data.links.this).to eq this_url
    end

  end

end