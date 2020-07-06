class UsersController < ApplicationController
before_action :set_user, only: [:edit, :update, :show, :destroy, :archived, :require_same_user]
before_action :set_active_templates, only: [:new, :edit, :show, :edit_multiple]
before_action :require_admin, except: [:index_student, :show]
before_action :require_same_user, only: [:show]


  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.first_name = @user.first_name.titlecase
    @user.last_name = @user.last_name.titlecase
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

  def advance_grades
    ninth_graders = User.find_by_sql"Update * FROM users INNER JOIN grades ON grades.id = users.grade_id WHERE grades.grade_level = 9"
    ninth_graders.update()
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

  def index_student
    if !logged_in_user_admin?
      redirect_to user_path(current_user)
    end


    @students = User.joins(:usertype).merge(Usertype.where(:user_type => 'student'))

    respond_to do |format|
      format.html
      format.csv { send_data @students.to_csv(['email', 'first_name', 'last_name']) }
    end
  end

  def index_supervisor
    @supervisors = User.joins(:usertype).merge(Usertype.where.not(:user_type => 'student'))
  end

  def show
    if !user_is_student?
      find_active_sheets_for_multiple_students
    end

    if user_is_student?
      find_active_sheets
    end
  end

  def find_active_sheets_for_multiple_students
    @students = User.where(supervisor_id: params[:id])
  end

  def find_active_sheets
    active_sheets = Sheet.where(template_id: @templates)
    @sheets = active_sheets.where(user_id: params[:id])
    @sheet_dates = @sheets.distinct.pluck(:date)
    sign_ins = @sheets.where("date <= ?", Date.yesterday())
    @total_sign_ins = sign_ins.count
    @total_worked = sign_ins.where(signed_in: true).count
    @total_missed = sign_ins.where(signed_in: false).count
  end

  def search
    user = params[:user]
    @searched_user = User.full_search(user)
    if @searched_user.count == 1
      redirect_to user_path(@searched_user.first)
    elsif @searched_user.count > 1
      flash[:notice] = "There was more that one search result. If this isn't the right person, do a more detailed search."
      redirect_to user_path(@searched_user.first)
    else
      flash[:alert] = "No one matched that search result."
      redirect_to root_path
    end
  end

  def edit_multiple
    @students = User.where(usertype_id: 1)
  end

  def update_multiple
    User.update(params[:students].keys, params[:students].values)
    # need to figure how to run this action for template_ids that have been updated: create_schedules_in_sheets(student.id, student.template_id)
    flash[:notice] = "Students has been updated."
    redirect_to root_path
  end

  def destroy
    if user_is_student?
      Sheet.where(user_id: @user).delete_all
    end
    if user_is_supervisor?
      User.where(supervisor_id: @user).update(supervisor_id: nil)
    end
    @user.destroy
    flash[:notice] = "#{@user.full_name} has been deleted."
    redirect_to root_path
  end

  def import
    User.import(params[:file])
    flash[:notice] = "Users have been imported."
    redirect_to root_path
  end

  def archived
    @sheets = Sheet.where(user_id: params[:id]).order(:date)
  end

  def progress_grades
    grades = Grade.all.order(grade_level: :desc)
    grades.each do |grade|
    	current_grade = grade.id
    	next_grade = grade.next_grade_id
    	User.where(grade_id: current_grade).update(grade_id: next_grade)
    end
    flash[:notice] = "All student grades have been advanced to their next grade"
    redirect_to root_path
  end

  def bulk_delete_students
    grade = Grade.where(next_grade_id: nil)
    users_to_delete = User.where(grade_id: grade)
    Sheet.where(user_id: users_to_delete).delete_all
    users_to_delete.destroy_all
    flash[:notice] = "All students with a next grade set to 'blank' has been deleted"
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

  def require_same_user
    # students = User.where(supervisor_id: params[:id])
    # student_ids = students.distinct.pluck(:id)
    if logged_in_user_student? && current_user.id != @user.id
      flash[:alert] = "You don't have access to other's page."
      redirect_to root_path
    end
    # if (logged_in_user_supervisor? && current_user.id != @user.id) || (logged_in_user_supervisor? && student_ids.include?(@user.id))
    #   flash[:alert] = "You don't have access that page."
    #   redirect_to root_path
    # end
  end

end
