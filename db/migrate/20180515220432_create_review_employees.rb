class CreateReviewEmployees < ActiveRecord::Migration[5.1]
  def change
    create_table :review_employees do |t|
      t.belongs_to :review, foreign_key: true
      t.belongs_to :employee, foreign_key: true

      t.timestamps
    end
  end
end
