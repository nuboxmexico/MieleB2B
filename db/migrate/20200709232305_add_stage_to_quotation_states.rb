class AddStageToQuotationStates < ActiveRecord::Migration[5.2]
  def change
    add_column :quotation_states, :stage, :integer
  end
end
