class ReviewEmployee < ApplicationRecord
  belongs_to :review
  belongs_to :employee
end
