class Review < ApplicationRecord
  has_many :review_employees, dependent: :destroy
  has_many :employees, through: :review_employees

  # class method to calculate/recalculate scores of the reviews
  def self.calculate_scores
    all.each {|r| r.calculate_score}
  end

  # SEE the README for how the review score is calculated
  def calculate_score
    temp_score = 0
    temp_score += rating*50
    temp_score += employees.count*10
    temp_score += good_words_count*7
    temp_score += determine_message_score
    self.score = temp_score
    self.save
  end

  def good_words_count
    # these are the good words we're looking for in the message to detect the positivity of the message left
    good_words = %w'friendly excellent best definitely good great amazing'
    # this will remove punctuation and divide the string into an array to be checked
    message_words = message.downcase.gsub(/[^a-z0-9\s]/i, '').split(' ')
    # gives us the count of how many good words were found in the message
    message_words.reject{ |w| !good_words.include? w}.count
  end

  def determine_message_score
    # a good rating with long message length gives more than short message. A bad rating with long memssage takes away more than a short message
    if rating >= 3
      message.length >= 400 ? 40 : 10
    else
      message.length >= 400 ? -40 : -10
    end
  end

end
