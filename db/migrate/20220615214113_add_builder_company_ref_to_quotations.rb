class AddBuilderCompanyRefToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_reference :quotations, :builder_company, foreign_key: true
  end
end
