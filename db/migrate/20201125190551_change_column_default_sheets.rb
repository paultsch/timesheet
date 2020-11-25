class ChangeColumnDefaultSheets < ActiveRecord::Migration[6.0]
  def change
    change_column_default :sheets, :signed_in, false
  end
end
