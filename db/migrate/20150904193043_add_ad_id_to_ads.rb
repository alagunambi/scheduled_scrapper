class AddAdIdToAds < ActiveRecord::Migration
  def change
    add_column :ads, :ad_id, :string
  end
end
