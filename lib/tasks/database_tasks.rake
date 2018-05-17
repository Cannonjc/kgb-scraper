namespace :db do
  desc 'Scrape and load, scrapes the website for reviews and loads proper info into the db'
  task scrape_and_load: :environment do
    require 'nokogiri'
    require 'open-uri'
    user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.854.0 Safari/535.2"
    # url = 'http://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/page' + 1.to_s + '/?filter=ALL_REVIEWS#link'
    url = "https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-review-23685/"
    # keep base url to append to
    base_url = "https://www.dealerrater.com"
    # open original url to start
    doc = Nokogiri::HTML(open(url, 'User-Agent' => user_agent))
    # find url to the page of reviews, link variable to be reused each iteration
    link = base_url + doc.at_css('#reviews').at_css('.hidden-xs')['href']
    # setting up reviews array to be inserted as bulk instead of 1 each time in loop
    reviews = []
    # loop 5 times to get 5 pages of reviews
    (1..5).each do |i|
      # open doc and get entries to iterate over
      current_doc = Nokogiri::HTML(open(link, 'User-Agent' => user_agent))
      entries = current_doc.css('.review-entry')
      entries.each do |entry|
        # gather review data
        date = entry.at_css('.review-date').at_css('.margin-none').text
        rating = entry.at_css('.margin-center')['class'].split(' ')[2][7..-1].to_f/10
        title = entry.at_css('h3').text[1..-2]
        user = entry.at_css('.notranslate').text[2..-1]
        message = entry.at_css('.review-content').text
        review = Review.new(date: date, rating: rating, title: title, user: user, message: message)
        # get employees, iterate and create them if needed
        emps = entry.css('.review-employee')
        unless emps.empty?
          emps.each do |e|
            name = e.at_css('.tagged-emp').text.strip
            rating = e.at_css('.boldest').nil? ? 0 : e.at_css('.boldest').text.to_f
            employee = Employee.find_or_create_by(name: name, rating: rating)
            review.review_employees.build(employee: employee)
          end
        end
        # add review object with employee associations to array for bulk import
        reviews << review
      end
      # reset link for next page
      link = base_url + current_doc.at_css('.next').child['href']
    end
    # import all reviews that have been put in reviews
    Review.import reviews, recursive: true
    # calculate all scores now that employees and reviews are associated
    Review.calculate_scores
    # query to get the top 3 scores, and ordered by date if there is a tie
    Review.order(score: :desc, updated_at: :desc).limit(3).each_with_index do |r, index|
      puts r.user + " was the " + (index+1).ordinalize + " worst offender with their review on " + r.date
    end
    puts "extra info... the most helpful employee is: " + Employee.get_most_helpful_employee.name + " - should we eliminate him?"
  end
end
