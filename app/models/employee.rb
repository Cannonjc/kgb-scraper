class Employee < ApplicationRecord
  has_many :review_employees, dependent: :destroy
  has_many :reviews, through: :review_employees
end
