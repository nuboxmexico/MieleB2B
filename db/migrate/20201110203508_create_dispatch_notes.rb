class CreateDispatchNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :dispatch_notes do |t|
      t.text :observation
      t.references :user, foreign_key: true
      t.references :dispatch_group, foreign_key: true
      t.integer :category

      t.timestamps
    end
  end
end
