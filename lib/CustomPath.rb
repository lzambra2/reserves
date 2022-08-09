class CustomPath < Devise::FailureApp
  def redirect
    redirect_to invalid_login_url
  end
end
