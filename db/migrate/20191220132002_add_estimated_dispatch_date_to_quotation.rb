class AddEstimatedDispatchDateToQuotation < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :estimated_dispatch_date, :date
  end
end
