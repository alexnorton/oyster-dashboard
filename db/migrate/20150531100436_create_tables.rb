class CreateTables < ActiveRecord::Migration
  def change
    create_table :journeys do |t|
      t.integer :from_id
      t.integer :to_id
      t.datetime :start_time
      t.datetime :end_time
      t.string :route
      t.string :type
      t.decimal :cost, :precision => 8, :scale => 2
    end

    create_table :locations do |t|
      t.string :name
    end
  end
end
