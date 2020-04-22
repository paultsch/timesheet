class YearsController < ApplicationController
before_action :set_year, only: [:edit, :update, :destroy]

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
  end

private

def year_params
  params.require(:year).permit(:year, :current_year)
end

  def set_year
    @year = Year.find(params[:id])
  end

end
