class CreateTemplates < ActiveRecord::Migration[6.0]
  def change
    create_table :templates do |t|
      t.belongs_to :templatetype
      t.belongs_to :year
      t.timestamps
    end
  end
end
