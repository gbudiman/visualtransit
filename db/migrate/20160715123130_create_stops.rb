class CreateStops < ActiveRecord::Migration
  def change
    create_table :stops do |t|
      t.string :tag, null: false
      t.string :name, null: false
      t.string :coord, null: false
      t.timestamps null: false
    end
  end
end
