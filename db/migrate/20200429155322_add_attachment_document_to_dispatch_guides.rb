class AddAttachmentDocumentToDispatchGuides < ActiveRecord::Migration[5.2]
  def self.up
    change_table :dispatch_guides do |t|
      t.attachment :document
    end
  end

  def self.down
    remove_attachment :dispatch_guides, :document
  end
end
