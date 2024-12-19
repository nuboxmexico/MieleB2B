class CreateImageNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :image_notes do |t|
      t.references :quotation_note, foreign_key: true

      t.timestamps
    end
  end
end
