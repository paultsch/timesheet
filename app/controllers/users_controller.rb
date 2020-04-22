class UsersController < ApplicationController
before_action :set_user, only: [:edit, :update, :show, :destroy]
before_action :set_active_templates, only: [:new, :edit]
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      if @user.template_id != nil
        create_schedules_in_sheets(@user.id, @user.template_id)
      end
      flash[:notice] = "User was successfully created"
      redirect_to root_path
    else
      flash[:alert] = @user.errors.full_messages.first
      redirect_to new_user_path
    end
  end

  def edit

  end

  def update
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    if @user.update(user_params)
      if @user.template_id != nil
        create_schedules_in_sheets(@user.id, @user.template_id)
      end
      flash[:notice] = "User was successfully updated"
      redirect_to user_path(@user)
    else
      flash[:alert] = @user.errors.full_messages.first
      redirect_to root_path
    end
  end

  def create_schedules_in_sheets(user, sche)
    @schedules = Schedule.where(template_id: sche)
    @schedules.each do |schedule|
      Sheet.create(user_id: user, template_id: schedule.template_id, date: schedule.date, signed_in: false)
    end
  end

  def delete_schedule_in_sheets
    @schedule = Sheet.where(user_id: params[:id], date: params[:date])

  end

  def index_student
    @students = User.joins(:usertype).merge(Usertype.where(:user_type => 'student'))
  end

  def index_supervisor
    @supervisors = User.joins(:usertype).merge(Usertype.where(:user_type => 'supervisor'))
  end

  def show
    @students = User.where(supervisor_id: params[:id])
    @sheets = Sheet.where(user_id: params[:id])
  end

  def update_multiple
    Sheet.update(params[:dates].keys, params[:dates].values)
    flash[:notice] = "The timesheet has been updated."
    redirect_to user_path(params[:id])
  end

  def destroy
    @user.destroy
    flash[:notice] = "#{@user.full_name} has been deleted."
    redirect_to root_path
  end

private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :usertype_id, :supervisor_id, :grade_id, :password, :password_confirmation, :template_id)
  end

  def sheet_params
    params.require(:sheet).permit(:date, :signed_in)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def set_active_templates
    @templates = Template.joins(:year).merge(Year.where(:current_year => true))
  end

end
