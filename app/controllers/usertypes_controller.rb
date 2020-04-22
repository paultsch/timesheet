class UsertypesController < ApplicationController
before_action :set_usertype, only: [:edit, :update, :destroy]

  def new
    @usertype = Usertype.new
  end

  def create
    @usertype = Usertype.new(usertype_params)
    if @usertype.save
      flash[:notice] = "The user type has been saved."
      redirect_to usertypes_path
    else
      flash[:alert] = @usertype.errors.full_messages.first
      redirect_to new_usertype_path
    end
  end

  def edit

  end

  def update
    if @usertype.update(usertype_params)
      flash[:notice] = "The usertype has been updated."
      redirect_to usertypes_path
    else
      flash[:notice] = "There was an issue updating your usertype."
      redirect_to edit_usertype_path([:id])
    end
  end

  def index
    @usertypes = Usertype.all
  end

  def destroy
    @usertype.destroy
    flash[:notice] = "User types was successfully removed."
    redirect_to usertypes_path
  end

private

def usertype_params
  params.require(:usertype).permit(:user_type)
end

def set_usertype
  @usertype = Usertype.find(params[:id])
end

end
