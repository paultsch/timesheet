class DashboardsController < ApplicationController

  def admin
    if !logged_in_user_admin?
      redirect_to user_path(current_user)
    end

    # @students = User.where(usertype_id: 1).order(:grade_id)
    # @students = User.all.select("id, first_name, last_name, grade_id, supervisor_id").where(usertype_id: 1).limit(5)
  @students = User.find_by_sql "SELECT u.id, u.first_name, u.last_name, u.grade_id, u.supervisor_id FROM users u WHERE usertype_id = 1"

  end

end

#
# User.find_by_sql"
# SELECT
#   u.id,
#   u.first_name,
#   u.last_name,
#   u.grade_id,
#   u.supervisor_id,
#   s.date
# FROM
#   users u
# INNER JOIN sheets s ON u.id = s.user_id
# WHERE u.usertype_id = 1"
