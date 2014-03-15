#coding: utf-8

require 'rubygems'
require 'Twitter'
require 'sinatra'
require 'sinatra/config_file'
require "open-uri"
require "FileUtils"

config_file 'config/app.yml'

client = nil

before do
  client = client || Twitter::REST::Client.new do |c|
    c.consumer_key = settings.twitter["auth"]["api-key"]
    c.consumer_secret = settings.twitter["auth"]["api-secret"]
    c.access_token = settings.twitter["auth"]["acess_token"]
    c.access_token_secret = settings.twitter["auth"]["acess_token_secret"]
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

get "/images" do
  count = get_count(params)
  max_id = get_max_id(params)
  result = get_favorited_images(client, count, max_id)
  
  urls = []
  result[:data].each do |e|
    e.media.each do |m|
      urls << "#{m.media_url}:large" if m
    end
  end
  
  content_type :json
  map = {urls: urls}
  map[:max_id] = result[:max_id] if result[:max_id]
  map[:error] = result[:error] if !result[:error].empty?
  map.to_json
end

get "/download" do
  count = get_count(params)
  max_id = get_max_id(params)
  result = get_favorited_images(client, count, max_id)
  
  json = {}
  json[:saved_images] = {}
  json[:existed_images] = {}
  json[:max_id] = result[:data][result[:data].size - 1].id - 1 if result[:data].size > 0
  result[:data].each do |e|
    e.media.each_index do |i|
      url = e.media[i].media_url
      idx = sprintf("%02d",i)
      filename = "#{e.id}_#{idx}" + File.extname(url)
      p filename
      dirname = File.join(File.dirname(__FILE__), settings.download_dir, e.user.id.to_s)
      FileUtils.mkdir_p(dirname) unless FileTest.exist?(dirname)
      
      filepath = File.join(dirname, filename)
      if FileTest.exist?(filepath)
        json[:existed_images][e.id] = filename
      else
        open(File.join(dirname, filename), 'wb') do |output|
          open(url) do |d|
            output.write(d.read)
          end
          json[:saved_images][e.id] = filename
        end
      end
    end
  end
  
  content_type :json
  json.to_json
end

helpers do
  def get_favorited_images(client, count, max_id)
    result = []
    error = []
    while result.size < count
      data = nil
      begin
        if !max_id
          data = client.favorites(settings.twitter["user"]["screen-name"], {count: count})
        else
          data = client.favorites(settings.twitter["user"]["screen-name"], {count: count, max_id: max_id})
        end
        p data
      rescue Twitter::Error::TooManyRequests => e
        error = "TooManyRequests";
        break;
      end
      
      break if !data || data.empty?
      
      data.each do |entity|
        result << entity if entity.media?
      end
      
      max_id = data[data.size-1].id - 1
    end
    
    return {data: result, max_id: max_id, error: error.uniq.compact}
  end
  
  def get_count(params)
    [[(params[:count].to_i || 20), 100].min, 1].max
  end
  
  def get_max_id(params)
    (params[:max_id] ? params[:max_id].to_i : nil)
  end
end
