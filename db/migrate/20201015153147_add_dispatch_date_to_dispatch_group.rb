class AddDispatchDateToDispatchGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :dispatch_groups, :dispatch_date, :date
  end
end
