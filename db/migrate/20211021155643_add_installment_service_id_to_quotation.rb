class AddInstallmentServiceIdToQuotation < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations , :installment_service_id, :string
  end
end
