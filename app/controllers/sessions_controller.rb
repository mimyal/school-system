class SessionsController < ApplicationController
  def index
    if  session[:user_id].nil?
      redirect_to login_failure_path
    else
      @user = User.find(session[:user_id]) # < recalls the value set in a previous request
      # implicit call to
      render :index
    end
  end

  def create # initiated from Github, we built it
    auth_hash = request.env['omniauth.auth']
    redirect to login_failure_path unless auth_hash['uid']

    @user = User.find_by(uid: auth_hash[:uid], provider: 'github')
    if @user.nil?
      # User doesn't match anything in the DB.
      # Attempt to create a new user.
      @user = User.build_from_github(auth_hash)
      render :creation_failure unless @user.save
    end
    # Save the user ID in the session
    session[:user_id] = @user.id

    redirect_to sessions_path # puts us to the index controller
  end

  def login_failure
  end

  def destroy
    session.delete(:user_id)
    redirect_to login_failure_path
  end


end
