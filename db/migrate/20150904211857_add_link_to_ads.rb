class AddLinkToAds < ActiveRecord::Migration
  def change
    add_column :ads, :link, :string
  end
end
