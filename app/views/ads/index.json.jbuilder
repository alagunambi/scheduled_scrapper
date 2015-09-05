json.array!(@ads) do |ad|
  json.extract! ad, :id, :title, :contact, :description, :user, :tag_id
  json.url ad_url(ad, format: :json)
end
