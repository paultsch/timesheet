class SheetsController < ApplicationController
  def sign_in_student
    @sheet = Sheet.where(user_id: params[:id], date: params[:date]).first
    @sheet.signed_in = true
    if @sheet.update(sheet_params)
      flash[:notice] = "You have successfully signed in"
      redirect_back(fallback_location: root_path)
    else
      flash[:notice] = "There was an issue signing you in."
      redirect_back(fallback_location: root_path)
    end
  end

  def unsign_in_student
    @sheet = Sheet.where(user_id: params[:id], date: params[:date]).first
    @sheet.signed_in = false
    if @sheet.update(sheet_params)
      flash[:notice] = "You have successfully unsigned in"
      redirect_back(fallback_location: root_path)
    else
      flash[:notice] = "There was an issue unsigning you in."
      redirect_back(fallback_location: root_path)
    end
  end

  def destroy_sheet
    @sheet = Sheet.where(user_id: params[:id], date: params[:date])
    @sheet.delete_all
    flash[:notice] = "Date has been deleted."
    redirect_back(fallback_location: root_path)
  end

  def create_sheet
    Sheet.create(user_id: params[:id], template_id: params[:template_id], date: params[:date], signed_in: false)
    flash[:notice] = "Date has been created."
    redirect_back(fallback_location: root_path)
  end

private

def sheet_params
  params.permit(:date, :signed_in)
end

end
