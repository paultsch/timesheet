class CreateTemplatetypes < ActiveRecord::Migration[6.0]
  def change
    create_table :templatetypes do |t|
      t.string :template_type
      t.timestamps
    end
  end
end
