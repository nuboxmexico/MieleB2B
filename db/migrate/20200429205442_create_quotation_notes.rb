class CreateQuotationNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :quotation_notes do |t|
      t.text :observation
      t.references :user, foreign_key: true
      t.references :quotation, foreign_key: true

      t.timestamps
    end
  end
end
