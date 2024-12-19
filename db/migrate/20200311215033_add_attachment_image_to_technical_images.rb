class AddAttachmentImageToTechnicalImages < ActiveRecord::Migration[5.2]
  def self.up
    change_table :technical_images do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :technical_images, :image
  end
end
