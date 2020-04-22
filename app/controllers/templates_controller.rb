class TemplatesController < ApplicationController
before_action :set_template, only: [:edit, :update, :destroy, :show]

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
    @schedule.template_id = params[:id]
    @schedule.date = params[:date]
    if @schedule.save
      flash[:notice] = "That date has been added."
      redirect_back(fallback_location: root_path)
    else
      flash[:notice] = "These was an issue adding that date."
      redirect_back(fallback_location: root_path)
    end
  end

  def delete_schedule_date
    @schedule = Schedule.where(template_id: params[:id], date: params[:date])
    if @schedule.destroy_all
      flash[:notice] = "That date has been deleted."
      redirect_back(fallback_location: root_path)
    else
      flash[:alert] = "These was an issue deleting that date."
      redirect_back(fallback_location: root_path)
    end
  end

  def index
    @templatetypes = Templatetype.all
    @years = Year.all
    @templates = Template.joins(:year).merge(Year.where(:current_year => true))
  end

  def destroy

  end

private

  def template_params
    params.require(:template).permit(:templatetype_id, :year_id)
  end

  def schedule_params
    params.permit(:template_id, :date)
  end

  def set_template
    @template = Template.find(params[:id])
  end

end
