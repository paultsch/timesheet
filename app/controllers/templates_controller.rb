class TemplatesController < ApplicationController
before_action :set_template, only: [:edit, :update, :destroy, :show]
before_action :require_admin

  def new
    @template = Template.new
  end

  def create
    @template = Template.new(template_params)
    if @template.save
      flash[:notice] = "The template was saved."
      redirect_to templates_path
    else
      flash[:alert] = "There was an issue saving the template."
      redirect_to new_template_path
    end
  end

  def edit
  end

  def update
    if @template.update(template_params)
      flash[:notice] = "The template has be updated."
      redirect_to templates_path
    else
      flash[:alert] = "There was an issue updating the template."
      redirect_to edit_template_path(@template)
    end
  end

  def show
    @schedules = Schedule.where(template_id: params[:id])
    @schedule_dates = @schedules.distinct.pluck(:date)
  end

  def add_schedule_date
    @schedule = Schedule.new(schedule_params)
    @template = params[:id]
    @date = params[:date]
    @schedule.template_id = @template
    @schedule.date = @date
    if @schedule.save
      add_date_to_sheets(@template, @date)
      flash[:notice] = "That date has been added."
      redirect_back(fallback_location: root_path)
    else
      flash[:notice] = "These was an issue adding that date."
      redirect_back(fallback_location: root_path)
    end
  end

  def add_date_to_sheets(template, date)
    @users = User.where(template_id: template)
    @users.each do |user|
      Sheet.create(user_id: user.id, template_id: template, date: date)
    end
  end

  def delete_schedule_date
    @template = params[:id]
    @date = params[:date]
    @schedule = Schedule.where(template_id: @template, date: @date)
    if @schedule.destroy_all
      delete_date_from_sheets(@template, @date)
      flash[:notice] = "That date has been deleted."
      redirect_back(fallback_location: root_path)
    else
      flash[:alert] = "These was an issue deleting that date."
      redirect_back(fallback_location: root_path)
    end
  end

  def delete_date_from_sheets(template, date)
    @sheets = Sheet.where(template_id: template, date: params[:date])
    @sheets.delete_all
  end

  def index
    @templatetypes = Templatetype.all
    @years = Year.all
    @templates = Template.joins(:year).merge(Year.where(:current_year => true))
  end

  def destroy
    template_to_delete = params[:id]
    templates = Template.find(template_to_delete)
    schedules = Schedule.where(template_id: templates)
    sheets = Sheet.where(template_id: templates)
    sheets.delete_all
    schedules.delete_all
    templates.delete
    flash[:alert] = "Template was successfully deleted and all its children."
    redirect_to templates_path
  end

private

  def template_params
    params.require(:template).permit(:templatetype_id, :year_id)
  end

  def schedule_params
    params.permit(:template_id, :date)
  end

  def sheet_params
    params.permit(:user_id, :template_id, :date, :signed_in)
  end

  def set_template
    @template = Template.find(params[:id])
  end

end
