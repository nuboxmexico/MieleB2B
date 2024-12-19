class AddCreditNoteToQuotation < ActiveRecord::Migration[5.2]
  def change
  	add_column :quotations, :credit_note, :string
  end
end
