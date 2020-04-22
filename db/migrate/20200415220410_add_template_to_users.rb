class AddTemplateToUsers < ActiveRecord::Migration[6.0]
  change_table :users do |t|
    t.belongs_to :template
  end
end
