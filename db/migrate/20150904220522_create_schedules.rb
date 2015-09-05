class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.integer :tag_id
      t.datetime :date
      t.integer :status

      t.timestamps null: false
    end
  end
end
