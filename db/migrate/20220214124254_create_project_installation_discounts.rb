class CreateProjectInstallationDiscounts < ActiveRecord::Migration[5.2]
  def change
    create_table :project_installation_discounts do |t|
      t.integer :min_amount
      t.integer :max_amount
      t.float :discount

      t.timestamps
    end
  end
end
