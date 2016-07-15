class CreateDirectionStops < ActiveRecord::Migration
  def change
    create_table :direction_stops do |t|
      t.belongs_to :direction, null: false
      t.belongs_to :stop, null: false
      t.timestamps null: false
    end
  end
end
