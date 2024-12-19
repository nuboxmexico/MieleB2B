class CreateDispatchGuides < ActiveRecord::Migration[5.2]
  def change
    create_table :dispatch_guides do |t|

      t.timestamps
    end
  end
end
