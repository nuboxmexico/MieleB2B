class AddStatusToLead < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :status, :integer, default: 0
  end
end
