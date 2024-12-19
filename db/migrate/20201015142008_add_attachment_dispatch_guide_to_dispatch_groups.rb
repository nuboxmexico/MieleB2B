class AddAttachmentDispatchGuideToDispatchGroups < ActiveRecord::Migration[5.2]
  def self.up
    change_table :dispatch_groups do |t|
      t.attachment :dispatch_guide
    end
  end

  def self.down
    remove_attachment :dispatch_groups, :dispatch_guide
  end
end
