class CreateQuotationStates < ActiveRecord::Migration[5.2]
  def change
    create_table :quotation_states do |t|
      t.string :name

      t.timestamps
    end
  end
end
