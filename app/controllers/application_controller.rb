class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  check_authorization

  before_action :login_required
  before_action :user_information_validity_check, if: :logged_in?

  def current_user
    @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def current_ability
    @current_ability ||= Ability.new(current_user, params)
  end

  def logged_in?
    current_user
  end

  def login_required
    unless logged_in? || controller_name == 'sessions'
      session[:redirect_to] = request.fullpath unless request.fullpath == login_path
      redirect_to login_url, alert: 'You must login before accessing this page'
    end
  end

  def user_information_validity_check
    if !current_user.admin && (current_user.name.blank? || current_user.email.blank?) && controller_name == 'users'
      redirect_to edit_user_path(current_user),
                  notice: "Please update your user information before continuing #{current_user.valid?}"
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to unauthorized_url, alert: "#{exception.message}"
  end
end
