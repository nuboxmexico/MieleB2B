class AddAttachmentFileToLeadAttachments < ActiveRecord::Migration[5.2]
  def self.up
    change_table :lead_attachments do |t|
      t.attachment :file
    end
  end

  def self.down
    remove_attachment :lead_attachments, :file
  end
end
