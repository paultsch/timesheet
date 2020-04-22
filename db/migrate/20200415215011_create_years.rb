class CreateYears < ActiveRecord::Migration[6.0]
  def change
    create_table :years do |t|
      t.string :year
      t.boolean :current_year
      t.timestamps
    end
  end
end
