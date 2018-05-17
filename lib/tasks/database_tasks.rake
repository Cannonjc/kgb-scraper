namespace :db do
  desc 'Scrape and load, scrapes the website for reviews and loads proper info into the db'
  task scrape_and_load: :environment do

    require 'nokogiri'
    require 'open-uri'
    user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.854.0 Safari/535.2"
    # url = 'http://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/page' + 1.to_s + '/?filter=ALL_REVIEWS#link'
    url = "https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-review-23685/"
    base_url = "https://www.dealerrater.com"
    doc = Nokogiri::HTML(open(url, 'User-Agent' => user_agent))
    link = base_url + doc.at_css('#reviews').at_css('.hidden-xs')['href']
    reviews = []
    (1..5).each do |i|
      current_doc = doc = Nokogiri::HTML(open(link, 'User-Agent' => user_agent))
      entries = doc.css('.review-entry')
      entries.each do |entry|
        date = entry.at_css('.review-date').at_css('.margin-none').text
        rating = entry.at_css('.margin-center')['class'].split(' ')[2][7..-1].to_f/10
        title = entry.at_css('h3').text[1..-2]
        user = entry.at_css('.notranslate').text[2..-1]
        message = entry.at_css('.review-content').text
        review = Review.new(date: date, rating: rating, title: title, user: user, message: message)
        emps = entry.css('.review-employee')
        unless emps.empty?
          emps.each do |e|
            name = e.at_css('.tagged-emp').text.strip
            rating = e.at_css('.boldest').nil? ? 0 : e.at_css('.boldest').text.to_f
            employee = Employee.find_or_create_by(name: name, rating: rating)
            review.review_employees.build(employee: employee)
          end
        end
        reviews << review
      end
      link = base_url + doc.at_css('.next').child['href']
    end
    Review.import reviews, recursive: true
    Review.calculate_scores
    Review.order(score: :desc, updated_at: :desc).limit(3).each_with_index do |r, index|
      puts r.user + " was the " + (index+1).ordinalize + " worst offender with their review on " + r.date
    end
  end
end
