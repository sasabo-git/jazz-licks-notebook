# frozen_string_literal: true

json.array! @scores do |score|
  json.call(score, :id, :title, :body, :key, :meter, :chord_progression)
end
