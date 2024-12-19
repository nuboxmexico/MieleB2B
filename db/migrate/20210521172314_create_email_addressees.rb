class CreateEmailAddressees < ActiveRecord::Migration[5.2]
  def change
    create_table :email_addressees do |t|
      t.references :user, foreign_key: true
      t.string :process, null: false
      t.datetime :deleted_at

      t.timestamps

      t.index :deleted_at
    end
  end
end
