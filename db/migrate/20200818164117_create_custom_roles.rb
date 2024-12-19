class CreateCustomRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_roles do |t|
      t.references :role, foreign_key: true
      t.references :sale_channel, foreign_key: true
      t.references :cost_center, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
