# frozen_string_literal: true

class Custompath < Devise::FailureApp
  def redirect
    redirect_to invalid_login_url
  end
end
