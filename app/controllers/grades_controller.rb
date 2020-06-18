class GradesController < ApplicationController
before_action :set_grade, only: [:edit, :update, :destroy]
before_action :require_admin

  def new
    @grade = Grade.new
  end

  def create
    @grade = Grade.new(grade_params)
    @grade.grade_level.to_i
    if @grade.save
      flash[:notice] = "The grade has been saved."
      redirect_to grades_path
    else
      flash[:notice] = @grade.errors.full_messages.first
      redirect_to new_grade_path
    end
  end

  def edit
  end

  def update
    if @grade.update(grade_params)
      flash[:notice] = "The grade has been updated."
      redirect_to grades_path
    else
      flash[:notice] = "There was an issue updating your grade."
      redirect_to edit_grade_path([:id])
    end
  end

  def index
    @grades = Grade.all
  end

  def destroy
    @grade.destroy
    flash[:notice] = "Grade was successfully removed."
    redirect_to grades_path
  end

private

def grade_params
  params.require(:grade).permit(:grade_level, :next_grade_id)
end

def set_grade
  @grade = Grade.find(params[:id])
end

end
