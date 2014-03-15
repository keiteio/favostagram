#coding: utf-8

require 'sinatra'

get '/' do
  @hello = "あなたのfavった画像はこちらです"
  erb :index
end