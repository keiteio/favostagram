#coding: utf-8

require 'sinatra'

get '/' do
  @hello = "あなたのfavった画像はこちらです"
  erb :index
end

get '/api/get_tweet.json' do
  limit  = [ (params[:count] || 30).to_i, 150 ].min
  page   = (params[:page] || 1).to_i
  offset = (page - 1) * limit
  max_page  = (150 / limit).ceil
  next_page = max_page > page ? page + 1 : nil

  tweets = Tweet.get({ :limit => limit,
                       :offset => offset })

  ActiveRecord::Base.include_root_in_json = false
  content_type :json
  {:datas => tweets, :next => next_page}.to_json
end


