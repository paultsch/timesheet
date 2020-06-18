class ApplicationController < ActionController::Base
before_action :authenticate_user!
before_action :configure_permitted_parameters, if: :devise_controller?
helper_method :user_is_admin?, :user_is_supervisor?, :user_is_student?, :logged_in_user_admin?, :logged_in_user_supervisor?, :logged_in_user_student?, :require_admin

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :email, :usertype_id, :supervisor_id, :grade_id])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :email, :usertype_id, :supervisor_id, :grade_id])
  end

  def logged_in_user_admin?
    if user_signed_in?
      current_user.usertype_id == 3
    end
  end

  def require_admin
    if current_user.usertype_id != 3
      flash[:alert] = "You must be an admin user to do that."
      redirect_to root_path
    end
  end

  def logged_in_user_supervisor?
    current_user.usertype_id == 2
  end

  def logged_in_user_student?
    current_user.usertype_id == 1
  end

  def user_is_admin?
    @user.usertype_id == 3
  end

  def user_is_supervisor?
    @user.usertype_id == 2
  end

  def user_is_student?
    @user.usertype_id == 1
  end

end
