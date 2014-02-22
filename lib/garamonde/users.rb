class Garamonde::Users

  def initialize
    @users = {}
  end

  def register(keyw = {})
    email = keyw[:email]
    return nil unless email

    existing_user(email) || new_user(email)
  end

  def sign_in(keyw = {})
    auth_code = keyw[:auth_code]

    new_session(auth_code)
  end

  def sign_out(keyw = {})
    auth_code = keyw[:auth_code]
   
    end_session(auth_code)
  end

  def authenticate(keyw = {})
    token = keyw[:token]

    user = lookup_session token
    if user
      yield OpenStruct.new(
        status: "authenticated",
        user: user,
        successful?: true
      )
    else
      yield OpenStruct.new(
        status: "invalid token"
      )
    end
  end

  private

  def existing_user(email)
    if user = @users[email]
      user.dup.tap do |u|
        u.status = "already registered"
      end
    end
  end

  def new_user(email)
    @users[email] = OpenStruct.new(
      status: "registered",
      email: email,
      auth_code: new_auth_code,
      sessions: []
    )
  end

  def new_auth_code
    SecureRandom.hex(16) 
  end

  def new_session(code)
    user = @users.values.detect{|u| u.auth_code == code }

    if user
      OpenStruct.new(
        status: "signed in",
        token: new_session_token(user),
        successful?: true
      )
    else
      OpenStruct.new(
        status: "invalid code"
      )
    end
  end

  def end_session(token)
    user = lookup_session token 
    
    if user
      user.sessions.delete token
      OpenStruct.new(
        status: "signed out",
        successful?: true
      )
    else
      OpenStruct.new(
        status: "invalid token"
      )
    end
  end

  def new_session_token(user)
    new_auth_code.tap do |code|
      user.sessions << code
    end
  end

  def lookup_session(token)
    @users.values.detect{|u| u.sessions.include? token }
  end

end
