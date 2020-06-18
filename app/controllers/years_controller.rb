class YearsController < ApplicationController
before_action :set_year, only: [:edit, :update, :destroy]
before_action :require_admin


  def new
    @year = Year.new
  end

  def create
    @year = Year.new(year_params)
    if @year.save
      flash[:notice] = "The year was successfully created."
      redirect_to templates_path
    else
      flash[:alert] = "There was an issue creating the year."
      redirect_to new_year_path
    end
  end

  def edit
  end

  def update
    if @year.update(year_params)
      flash[:notice] = "The year was successfully updated."
      redirect_to templates_path
    else
      flash[:alert] = "There was an issue updating the year."
      redirect_to edit_year_path([:id])
    end
  end

  def destroy
      year_to_delete = params[:id]
      year = Year.find(year_to_delete)
      templates = Template.where(year_id: year.id)
      schedules = Schedule.where(template_id: templates)
      sheets = Sheet.where(template_id: templates)
      sheets.delete_all
      schedules.delete_all
      templates.delete_all
      year.delete
      flash[:alert] = "Year was successfully deleted year and all its children."
      redirect_to templates_path
  end

private

def year_params
  params.require(:year).permit(:year, :current_year)
end

  def set_year
    @year = Year.find(params[:id])
  end

end
