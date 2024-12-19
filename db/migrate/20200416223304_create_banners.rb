class CreateBanners < ActiveRecord::Migration[5.2]
  def change
    create_table :banners do |t|
      t.text :url
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
