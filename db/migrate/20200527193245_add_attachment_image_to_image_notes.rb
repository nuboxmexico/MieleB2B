class AddAttachmentImageToImageNotes < ActiveRecord::Migration[5.2]
  def self.up
    change_table :image_notes do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :image_notes, :image
  end
end
