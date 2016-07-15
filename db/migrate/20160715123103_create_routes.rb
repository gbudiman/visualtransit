class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.belongs_to :agency, null: false
      t.string :tag, null: false
      t.string :name, null: false
      t.timestamps null: false
    end
  end
end
