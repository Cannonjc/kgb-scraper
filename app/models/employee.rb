class Employee < ApplicationRecord
  has_many :review_employees, dependent: :destroy
  has_many :reviews, through: :review_employees

  # this is for some fun, seeing the challenge i thought it would be fun to find the most helpful employee to... get rid of?
  def self.get_most_helpful_employee
    Employee.joins(:review_employees).select("employees.*, count(review_employees.id) as ecount").group("employees.id").order("ecount DESC").first
  end
end
