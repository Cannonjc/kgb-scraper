class ChangeDateToStringOnReview < ActiveRecord::Migration[5.1]
  def change
    change_column :reviews, :date, :string
  end
end
