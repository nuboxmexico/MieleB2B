class CreateMieleRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :miele_roles do |t|
      t.string :code
      t.string :name
      t.string :classification

      t.timestamps
    end
  end
end
