class AddRoleToDispatchGuide < ActiveRecord::Migration[5.2]
  def change
    add_reference :dispatch_guides, :role, foreign_key: true
  end
end
