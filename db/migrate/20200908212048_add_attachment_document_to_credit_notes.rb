class AddAttachmentDocumentToCreditNotes < ActiveRecord::Migration[5.2]
  def self.up
    change_table :credit_notes do |t|
      t.attachment :document
    end
  end

  def self.down
    remove_attachment :credit_notes, :document
  end
end
