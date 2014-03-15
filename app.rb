require 'rubygems'
require 'Twitter'
require 'sinatra'
require 'sinatra/config_file'

config_file 'config/app.yml'

client = nil

before do
  client = client || Twitter::REST::Client.new do |c|
    c.consumer_key = settings.twitter["auth"]["api-key"]
    c.consumer_secret = settings.twitter["auth"]["api-secret"]
    #c.access_token = settings.twitter["auth"]["acess_token"]
    #c.access_token_secret = settings.twitter["auth"]["acess_token_secret"]
  end
end

get "/" do
  data = client.favorites(settings.twitter["user"]["screen-name"])
  
  html = ""
  data.each do |entity|
    html += "<img src='#{entity.media[0].media_url}'/><br>" if entity.media[0]
  end
  
  html
end




