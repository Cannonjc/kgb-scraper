class CreateReviews < ActiveRecord::Migration[5.1]
  def change
    create_table :reviews do |t|
      t.datetime :date
      t.float :rating, default: 0
      t.string :title
      t.string :user
      t.text :message, default: ""

      t.timestamps
    end
  end
end
