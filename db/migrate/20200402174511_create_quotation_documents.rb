class CreateQuotationDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :quotation_documents do |t|
      t.references :quotation, foreign_key: true

      t.timestamps
    end
  end
end
