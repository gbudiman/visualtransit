class CreateDirections < ActiveRecord::Migration
  def change
    create_table :directions do |t|
      t.belongs_to :route, null: false
      t.string :title, null: false
      t.string :name, null: false
      t.timestamps null: false
    end
  end
end
