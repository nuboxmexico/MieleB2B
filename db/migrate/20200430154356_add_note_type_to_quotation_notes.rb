class AddNoteTypeToQuotationNotes < ActiveRecord::Migration[5.2]
  def change
    add_column :quotation_notes, :note_type, :string
  end
end
