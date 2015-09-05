class CreateAds < ActiveRecord::Migration
  def change
    create_table :ads do |t|
      t.string :title
      t.string :contact
      t.text :description
      t.string :user
      t.integer :tag_id

      t.timestamps null: false
    end
  end
end
