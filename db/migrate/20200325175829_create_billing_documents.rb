class CreateBillingDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :billing_documents do |t|

      t.timestamps
    end
  end
end
