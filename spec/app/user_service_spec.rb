require_relative '../spec_helper'

require 'garamonde/app/app'

describe Garamonde::App do
  include RackHelpers

  it "should have a root path" do
    get "/"
    expect(last_response).to be_ok
  end

  context "/users" do

    it "should allow registering by email" do
      register email: "fwiffo@spathiwa.com"
      expect(last_response).to be_ok
      expect(response_data.status).to eq "registered"
      expect(response_data.user.email).to eq "fwiffo@spathiwa.com"
      expect(response_data.user.auth_code).not_to be_nil
    end

    it "should reject a registration without an email" do
      register bogus: 'fail'
      expect(last_response).not_to be_ok
      expect(response_data.status).to eq "missing email"
    end

    it "should allow registering with the same email" do
      register email: "fwiffo@spathiwa.com"
      first_data = response_data

      register email: "fwiffo@spathiwa.com"
      expect(last_response).to be_ok
      expect(response_data.status).to eq "already registered"
      expect(response_data.user.auth_code).to eq first_data.user.auth_code

      register email: "zelnick@earth.com"
      expect(response_data.user.auth_code).not_to eq first_data.user.auth_code
    end
    
  end

  context "/user/sessions" do

    it "should accept an auth code and return a token" do
      register email: "fwiffo@spathiwa.com"
      code = response_data.user.auth_code

      sign_in code
      expect(last_response).to be_ok
      expect(response_data.status).to eq "signed in"
      expect(response_data.session.token).to be_kind_of(String)
    end

    it "should reject an invalid auth code" do
      sign_in "bogus"
      expect(last_response).not_to be_ok
      expect(response_data.status).to eq "invalid code"
    end

    it "should allow sessions to be ended" do
      register email: "fwiffo@spathiwa.com"
      sign_in response_data.user.auth_code
      token = response_data.session.token

      sign_out token
      expect(last_response).to be_ok
      expect(response_data.status).to eq "signed out"
      
      sign_out token
      expect(last_response).not_to be_ok
      expect(response_data.status).to eq "invalid token"
    end

  end

end
