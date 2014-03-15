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
  data = client.favorites(settings.twitter["user"]["screen-name"], {max_id: 444373267336290304-1} )
  
  html = ""
  data.each do |entity|
    html += "<img src='#{entity.media[0].media_url}'/><br>" if entity.media[0]
  end
  
  html
end

get "/images" do
  count = params[:count] || 20
  max_id = params[:max_id]
  
  urls = []
  
  while urls.size < count
    data = client.favorites(settings.twitter["user"]["screen-name"], {max_id: 444373267336290304-1} )
    data.each do |entity|
      urls << entity.media[0].media_url if entity.media[0]
    end
    data[data.size-1]
  end
  
end


