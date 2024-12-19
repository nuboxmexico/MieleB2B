class AddCoreIdToCommunes < ActiveRecord::Migration[5.2]
  def change
    add_column :communes, :core_id, :string
  end
end
