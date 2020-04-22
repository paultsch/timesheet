class CreateSheets < ActiveRecord::Migration[6.0]
  def change
    create_table :sheets do |t|
      t.belongs_to :user
      t.belongs_to :template
      t.date :date
      t.boolean :signed_in
      t.timestamps
    end
  end
end
