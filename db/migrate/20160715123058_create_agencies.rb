class CreateAgencies < ActiveRecord::Migration
  def change
    create_table :agencies do |t|
      t.string :name, null: false
      t.timestamps null: false
    end
  end
end
