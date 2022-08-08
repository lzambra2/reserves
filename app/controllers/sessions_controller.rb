class SessionsController < ApplicationController
  skip_authorization_check except: %i[login_as back_to_my_login]

  def new
    uid = request.headers['HTTP_PYORK_USER']

    user = User.find_by_uid(uid)

    if user

      if user.active?
        session[:user_id] = user.id
        session[:username] = uid
        pp request.headers['HTTP_PYORK_CYIN']
        update_successful = user.update_external(request.headers['HTTP_PYORK_CYIN'])
        if update_successful
          user.audit_comment = 'Updated user information from ALMA'
          user.save(validate: false)
        end

        if session[:redirect_to].nil?
          redirect_to root_url, notice: 'Logged in!' if user.admin?
          redirect_to requests_user_url(user), notice: 'Welcome back!' unless user.admin?
        else
          url = session[:redirect_to]
          session[:redirect_to] = nil
          redirect_to url, notice: 'Logged in!'
        end

      else
        redirect_to inactive_user_url, alert: 'Your Account Has Been Disabled'
      end

    else
      # user is new, lets make one
      @user = User.new
      # try prefilling
      update_successful = @user.update_external(request.headers['HTTP_PYORK_CYIN'])

      @user.admin = false
      @user.active = true
      @user.user_type = User::UNKNOWN if @user.user_type.nil?
      @user.role = User::INSTRUCTOR_ROLE
      @user.uid = uid
      @user.audit_comment = 'Creating new auto-logged in user...from ALMA data'

      @user.save(validate: false)

      session[:user_id] = @user.id
      session[:username] = @user.uid

      if update_successful
        UserMailer.welcome(@user).deliver_later unless @user.email.nil?
        redirect_to requests_user_url(@user), notice: 'Welcome!'
      else
        redirect_to edit_user_url(@user), notice: 'Welcome! Please tell us about yourself.'
      end
    end

    # redirect_to invalid_login_url, alert:  "Invalid username or password #{uid}"
  end

  def destroy
    session[:user_id] = nil
    session[:username] = nil

    cookies.delete('mayaauth', domain: 'yorku.ca')
    cookies.delete('pybpp', domain: 'yorku.ca')

    redirect_to 'http://www.library.yorku.ca', allow_other_host: true
  end

  def invalid_login
    render layout: 'simple'
  end

  def unauthorized
    render layout: 'simple'
  end

  def inactive_account_url
    render layout: simple
  end

  def login_as
    authorize! :login_as, :requestor

    who = params[:who]
    requestor = User.find_by_id(who)

    if requestor && !requestor.admin?
      session[:back_to_id] = current_user.id
      name = current_user.name

      session[:user_id] = requestor.id
      session[:username] = requestor.uid
      session[:back_to_url] = request.referer

      ## updated audit trail
      requestor.audit_comment = "#{name} logged into #{requestor.name}'' account"
      requestor.save(validate: false)

      redirect_to requests_user_url(requestor)
    else
      redirect_to root_url, notice: 'Requestor not found'
    end
  end

  def back_to_my_login
    authorize! :back_to_login, :requestor

    unless session[:back_to_id].nil?
      requestor = current_user

      u = User.find_by_id(session[:back_to_id])

      ## updated audit trail
      requestor.audit_comment = "#{u.name} logged out from #{requestor.name}'s account"
      requestor.save(validate: false)

      session[:user_id] = u.id
      session[:username] = u.uid
      session[:back_to_id] = nil

      if session[:back_to_url].nil?
        redirect_to root_url
      else
        redirect_to session[:back_to_url]
      end
    end
  end
end
