require 'test_helper'

class ReviewTest < ActiveSupport::TestCase
  test "the truth" do
    puts "testing"
    assert true
  end

  test "calculate 1 star score" do
    puts "1 star should be 40: 50 for the star and -10 for the under 400 char message"
    @review = Review.new(date: "Today", title: "TESTING", rating: 1, message: "", user: "1 star guy")
    @review.save
    @review.calculate_score
    assert @review.score === 40, "psych"
    puts "score!"
  end
  test "calculate 1 star score with long message" do
    puts "1 star should be 10 - 50 for the star and -40 for the under 400 char message"
    @review = Review.create(date: "Today",
      rating: 1,
      message: "After a long and stormy night, a wooden vessel rolls through the Indian Sea with cargo to deliver peacefully. The winds had calmed down, though this surprised no one in the crew, given how predictable the wind in this little part of the world is. The flag, which notably did NOT have a skull of any kind on it, flied through the light breeze. Below deck lies most of the crew, when one sailor shouts.",
      user: "1 star guy - long message")
    @review.calculate_score
    assert @review.score === 10, "psych"
    puts "score!"
  end
end
