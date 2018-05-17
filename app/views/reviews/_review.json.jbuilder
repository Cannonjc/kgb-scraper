json.extract! review, :id, :date, :rating, :title, :user, :message, :created_at, :updated_at
json.url review_url(review, format: :json)
