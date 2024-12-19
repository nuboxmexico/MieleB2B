class AddItemsAndDeleteToProjectDispatchRules < ActiveRecord::Migration[5.2]
  def change
    remove_column :project_dispatch_rules, :project_percentage
    add_column :project_dispatch_rules, :mda, :integer
    add_column :project_dispatch_rules, :sda, :integer
    add_column :project_dispatch_rules, :pai, :integer
    rename_table :project_dispatch_rules, :dispatch_rules
    
  end
end
