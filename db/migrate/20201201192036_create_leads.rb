class CreateLeads < ActiveRecord::Migration[5.2]
  def change
    create_table :leads do |t|
      t.string :name
      t.string :real_state_name
      t.text :contacts
      t.string :project_address
      t.date :start_date_estimated
      t.integer :currency
      t.text :observations

      t.timestamps
    end
  end
end
