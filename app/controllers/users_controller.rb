class UsersController < ApplicationController
before_action :set_user, only: [:edit, :update, :show, :destroy, :archived]
before_action :set_active_templates, only: [:new, :edit, :show]
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
      #@templates = Template.joins(:year).merge(Year.where(:current_year => true))
      #@active_templates = @templates.distinct.pluck(:id)

      #if @active_templates.include?(@user.template_id)
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
    @sheets = Sheet.where(user_id: user)
    @sheet_dates = @sheets.distinct.pluck(:date)
    @schedule_dates = @schedules.distinct.pluck(:date)
    if @sheets.count > 0
      @sheets.each do |sheet|
        if (@schedule_dates.exclude?(sheet.date) && sheet.template.year.current_year == true)
          @sheets.where(date: sheet.date).delete_all
        end
      end
    end
    @schedules.each do |schedule|
      if @sheet_dates.include?(schedule.date)
        sheet = @sheets.where(date: schedule.date)
        sheet.update(template_id: sche)
      else
        Sheet.create(user_id: user, template_id: schedule.template_id, date: schedule.date, signed_in: false)
      end
    end
  end

  def non_active_years
    user = params[:id]
    inactive_templates_initial_pull = Template.joins(:year).merge(Year.where(:current_year => false))
    inactive_templates = inactive_templates_initial_pull.distinct.pluck(:template_id)
    @sheets = Sheet.where(user_id: user, template_id: inactive_templates)
  end

  def index_student
    @students = User.joins(:usertype).merge(Usertype.where(:user_type => 'student'))

    respond_to do |format|
      format.html
      format.csv { send_data @students.to_csv }
    end
  end

  def index_supervisor
    @supervisors = User.joins(:usertype).merge(Usertype.where(:user_type => 'supervisor'))
  end

  def show
    @students = User.where(supervisor_id: params[:id])
    active_sheets = Sheet.where(template_id: @templates)
    #@sheets = student_sheet.templates.includes(:years).where('years.current_year = ?', true)
    #Sheet.includes(:users, :templates).where('users.id = ? AND templates.year.current_year = ?', params[:id], true)
    #@sheets = student_sheet.where('template.year.current_year = ?', params[:id], true)
    @sheets = active_sheets.where(user_id: params[:id])
    @sheet_dates = @sheets.distinct.pluck(:date)
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

  def import
    User.import(params[:file])
    flash[:notice] = "Users have been imported."
    redirect_to users_students_path
  end

  def archived
    @sheets = Sheet.where(user_id: params[:id]).order(:date)
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

  def set_active_sheet

  end

  def set_active_templates
    @templates = Template.joins(:year).merge(Year.where(:current_year => true))
  end

end
