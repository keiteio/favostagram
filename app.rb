#coding: utf-8

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

  @html = ""
  data.each do |entity|
    @html += "<img src='#{entity.media[0].media_url}'/><br>" if entity.media[0]
  end

  erb :index
end

get '/api/get_tweet.json' do
  limit  = [ (params[:count] || 30).to_i, 150 ].min
  page   = (params[:page] || 1).to_i
  offset = (page - 1) * limit
  max_page  = (150 / limit).ceil
  next_page = max_page > page ? page + 1 : nil

  datas = client.favorites(settings.twitter["user"]["screen-name"])

  content_type :json
  {:datas => datas, :next => next_page}.to_json
end




