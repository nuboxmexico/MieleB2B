class AddAttachmentDocumentToSellNoteDocuments < ActiveRecord::Migration[5.2]
  def self.up
    change_table :sell_note_documents do |t|
      t.attachment :document
    end
  end

  def self.down
    remove_attachment :sell_note_documents, :document
  end
end
