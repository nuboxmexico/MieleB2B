class AddVisitReportUrlToDispatchgroup < ActiveRecord::Migration[5.2]
  def change
    add_column :dispatch_groups , :visit_report_url, :string
  end
end
