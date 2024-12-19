class AddAttachmentDocumentToBillingDocuments < ActiveRecord::Migration[5.2]
  def self.up
    change_table :billing_documents do |t|
      t.attachment :document
    end
  end

  def self.down
    remove_attachment :billing_documents, :document
  end
end
