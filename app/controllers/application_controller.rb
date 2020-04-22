class ApplicationController < ActionController::Base
before_action :authenticate_user!
before_action :configure_permitted_parameters, if: :devise_controller?
helper_method :user_admin?, :user_supervisor?, :user_student?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :email, :usertype_id, :supervisor_id, :grade_id])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :email, :usertype_id, :supervisor_id, :grade_id])
  end



  def user_admin?
    if current_user.usertype_id = 3
      return true
    else
      return false
    end
  end

  def user_supervisor?
    current_user.usertype_id = 2
  end

  def user_student?
    current_user.usertype_id = 1
  end

end
