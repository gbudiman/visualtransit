class CreatePaths < ActiveRecord::Migration
  def change
    create_table :paths do |t|
      t.belongs_to :route, null: false
      t.text :coord, null: false
      t.timestamps null: false
    end
  end
end
