require 'httparty'
require 'json'

response = HTTParty.post("https://www.reddit.com/r/nba.json")

# p JSON.parse(response.body)['data']['children'][1]['data']['url']

# HTTParty.p
