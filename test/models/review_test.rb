require 'test_helper'

class ReviewTest < ActiveSupport::TestCase
  test "the truth" do
    puts "testing"
    assert true
  end

  # Testing getting the top 3 guys
  test "puts out the top 3 guys in order" do
    @reviews = Review.order(score: :desc, updated_at: :desc).limit(3)
    assert @reviews.first === Review.find_by(score: 10), "First place not working"
    assert @reviews.second === Review.find_by(score: 9), "Second place not working"
    assert @reviews.last === Review.find_by(score: 8), "Third place not working"
    puts "All three passed!"
  end
  test "resolves a tie in the top 3" do
    @new_review = Review.create(date: "Most recent", title: "New Top Guy!", rating: 1, message: "", user: "newest user", score: 10)
    @reviews = Review.order(score: :desc, updated_at: :desc).limit(3)
    assert @reviews.first === @new_review, "new guy didnt make it"
    assert (Review.where(score: 10).include? @reviews.second), "second place guy messed up"
    assert @reviews.last === Review.find_by(score: 9), "third place after new guy not working"
    puts "new guy is now the top dog in tie break!"
  end

  # Testing message length mostly (and star multiplier)
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
  test "calculate 5 star score" do
    puts "5 star should be 260: 50 for each star and 10 for the under 400 char message"
    @review = Review.new(date: "Today", title: "TESTING", rating: 5, message: "", user: "5 star guy")
    @review.save
    @review.calculate_score
    assert @review.score === 260, "psych"
    puts "score!"
  end
  test "calculate 5 star score with long message" do
    puts "5 star should be 290 - 50 for each star and 40 for the under 400 char message"
    @review = Review.create(date: "Today",
      rating: 5,
      message: "After a long and stormy night, a wooden vessel rolls through the Indian Sea with cargo to deliver peacefully. The winds had calmed down, though this surprised no one in the crew, given how predictable the wind in this little part of the world is. The flag, which notably did NOT have a skull of any kind on it, flied through the light breeze. Below deck lies most of the crew, when one sailor shouts.",
      user: "5 star guy - long message")
    @review.calculate_score
    assert @review.score === 290, "psych"
    puts "score!"
  end

  # Testing good words
  test "calculates 1 star and no good words" do
    puts "1 star, no message, no good words should be (50-10+0 = 40)"
    @review = Review.create(date: "Today", title: "TESTING", rating: 1, message: "", user: "1 star guy")
    @review.calculate_score
    assert @review.score === 40, "no good words, 1 star, is wrong"
    puts "no good words 1 star passed!"
  end
  test "calculates 1 star and 1 good words" do
    puts "1 star, short message, 1 good word should be (50-10+7 = 47)"
    @review = Review.create(date: "Today", title: "TESTING", rating: 1, message: "good", user: "1 star guy")
    @review.calculate_score
    assert @review.score === 47, "1 good word, 1 star, is wrong"
    puts "1 good word 1 star passed!"
  end
  test "calculates 1 star and 5 good words" do
    puts "1 star, short message, 5 good words should be (50-10+(5*7) = 75)"
    @review = Review.create(date: "Today", title: "TESTING", rating: 1, message: "This is a good message. This is a good message. This is a good message. This is a good message. This is a good message.", user: "1 star guy")
    @review.calculate_score
    assert @review.score === 75, "5 good words, 1 star, is wrong"
    puts "5 good words 1 star passed!"
  end

  # Testing employee count
  test "1 star, short message, 0 employees worked with" do
    puts "1 star, short message, 0 employees should be (50-10+0 = 40)"
    @review = Review.create(date: "Today", title: "TESTING", rating: 1, message: "", user: "1 star guy")
    @review.calculate_score
    assert @review.score === 40, "0 employees 1 star, is wrong"
    puts "0 employees 1 star passed!"
  end
  test "1 star, short message, 1 employees worked with" do
    puts "1 star, short message, 1 employees should be (50-10+10 = 50)"
    @review = Review.create(date: "Today", title: "TESTING", rating: 1, message: "", user: "1 star guy")
    @review.employees.create(name: "new emp", rating: 5)
    @review.calculate_score
    assert @review.score === 50, "1 employees 1 star, is wrong"
    puts "0 employees 1 star passed!"
  end
  test "1 star, short message, 5 employees worked with" do
    puts "1 star, short message, 5 employees should be (50-10+50 = 90)"
    @review = Review.create(date: "Today", title: "TESTING", rating: 1, message: "", user: "1 star guy")
    @review.employees.create(name: "new emp", rating: 5)
    @review.employees.create(name: "new emp1", rating: 5)
    @review.employees.create(name: "new emp2", rating: 5)
    @review.employees.create(name: "new emp3", rating: 5)
    @review.employees.create(name: "new emp4", rating: 5)
    @review.calculate_score
    assert @review.score === 90, "5 employees 1 star, is wrong"
    puts "5 employees 1 star passed!"
  end

  # Testing class method calculate_scores
  test "calculate scores" do
    puts "all seeded info was initialized with wrong scores(on purpose), running the class method to make sure scores update"
    assert Review.find_by(user: "user3.5").score === 1, "initial data wrong? - 1"
    assert Review.find_by(user: "user4.5").score === 2, "initial data wrong? - 2"
    assert Review.find_by(user: "user5.0").score === 3, "initial data wrong? - 3"
    Review.calculate_scores
    assert_not Review.find_by(user: "user3.5").score === 1, "assert not 1"
    assert_not Review.find_by(user: "user4.5").score === 2, "assert not 2"
    assert_not Review.find_by(user: "user5.0").score === 3, "assert not 3"
    puts "calculate scores working!"
  end
end
