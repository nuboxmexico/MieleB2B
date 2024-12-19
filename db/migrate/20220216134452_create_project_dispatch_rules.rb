class CreateProjectDispatchRules < ActiveRecord::Migration[5.2]
  def change
    create_table :project_dispatch_rules do |t|
      t.string :region_name
      t.integer :min_amount
      t.integer :max_amount
      t.float :project_percentage

      t.timestamps
    end
  end
end
