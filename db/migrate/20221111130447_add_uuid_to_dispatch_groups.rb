class AddUuidToDispatchGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :dispatch_groups, :dispatch_uuid, :string

    DispatchGroup.all.each { |item| item.update(dispatch_uuid: SecureRandom.uuid) if item.dispatch_uuid.nil? || item.dispatch_uuid.blank? }
  end
end
