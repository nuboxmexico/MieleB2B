class CreateProjectInstalationValues < ActiveRecord::Migration[5.2]
  def change
    create_table :project_instalation_values do |t|
      t.integer :min_amount
      t.integer :max_amount
      t.decimal :cost_RM
      t.decimal :cost_additional_region

      t.timestamps
    end
  end
end
