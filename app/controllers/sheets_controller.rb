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

private

def sheet_params
  params.permit(:date, :signed_in)
end

end
