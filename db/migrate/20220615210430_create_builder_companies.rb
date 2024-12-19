class CreateBuilderCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :builder_companies do |t|
      t.string :name
      t.string :rut
      t.string :sector
      t.references :real_state_company, foreign_key: true

      t.timestamps
    end
  end
end
