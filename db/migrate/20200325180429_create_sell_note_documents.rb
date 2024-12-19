class CreateSellNoteDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :sell_note_documents do |t|

      t.timestamps
    end
  end
end
