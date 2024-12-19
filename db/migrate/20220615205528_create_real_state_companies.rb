class CreateRealStateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :real_state_companies do |t|
      t.string :name

      t.timestamps
    end
  end
end
