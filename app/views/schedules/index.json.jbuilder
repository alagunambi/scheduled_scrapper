json.array!(@schedules) do |schedule|
  json.extract! schedule, :id, :tag_id, :date, :status
  json.url schedule_url(schedule, format: :json)
end
