class TemplatetypesController < ApplicationController
before_action :set_templatetype, only: [:edit, :update, :destroy]

  def new
    @templatetype = Templatetype.new
  end

  def create
    @templatetype = Templatetype.new(templatetype_params)
    if @templatetype.save
      flash[:notice] = "Your template type has saved."
      redirect_to templates_path
    else
      flash[:alert] = "There was an issue saving your template type."
      redirect_to new_templatetype_path
    end
  end

  def index
  end

  def edit
  end

  def update
    if @templatetype.update(templatetype_params)
      flash[:notice] = "Your template type has been updated."
      redirect_to templates_path
    else
      flash[:alert] = "There was an issue updating your template type."
      redirect_to edit_templatetype_path([:id])
    end
  end

  def destory
  end

private

  def templatetype_params
    params.require(:templatetype).permit(:template_type)
  end

  def set_templatetype
    @templatetype = Templatetype.find(params[:id])
  end

end
