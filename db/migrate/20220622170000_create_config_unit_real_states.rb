class CreateConfigUnitRealStates < ActiveRecord::Migration[5.2]
  def change
    create_table :config_unit_real_states do |t|
      t.string :config_type
      t.string :config_number
      t.references :quotation, foreign_key: true

      t.timestamps
    end
  end
end
