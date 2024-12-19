class AddTechnicianIdToDispatchGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :dispatch_groups, :technician_id, :string
  end
end
