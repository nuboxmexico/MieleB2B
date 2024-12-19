class AddAttachmentBannerMobileToBanners < ActiveRecord::Migration[5.2]
  def self.up
    change_table :banners do |t|
      t.attachment :banner_mobile
    end
  end

  def self.down
    remove_attachment :banners, :banner_mobile
  end
end
