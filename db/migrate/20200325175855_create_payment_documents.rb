class CreatePaymentDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_documents do |t|

      t.timestamps
    end
  end
end
