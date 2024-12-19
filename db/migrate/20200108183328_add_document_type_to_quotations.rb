class AddDocumentTypeToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :document_type, :string
  end
end
