# README

This is a simple app to scrape a few pages of reviews, to find the most overly positive reviews.

To set up, you'll need Rails 5 installed<br>
Ruby 2.4.1<br>
Postgresql Server running.

To set up the database, run:<br>
rails db:create db:migrate

Then to get all the info scraped and loaded into the database, run:<br>
rails db:scrape_and_load
- In the console you'll see the top offenders listed! See below to see how their severity was determined

If you need to reset the database, run:<br>
rails db:reset db:migrate<br>
(if you have a GUI connected to the database, it might not allow you to reset the db)

After being scraped, the reviews are then given a score. The higher the score, the more positive the review was!<br>
The score is determined as follows:<br>
The rating is multiplied by 50,<br>
then added 10 for each employee associated with the review,<br>
after 7 is added for each 'positive word' found in its message - (friendly, excellent, best, definitely, good, great, amazing)<br>
then, if the rating was above 3 stars, 40 would be added if the message was more than 400 characters, or 10 if not<br>
otherwise if the rating was below 3 stars, 40 would be subtracted if the message was more than 400 characters, or 10 if not.<br>

Ultimately if there was a tie in scores, then they would be ordered by date, more recent being listed higher
