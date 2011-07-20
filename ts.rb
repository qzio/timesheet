require 'rubygems'
require 'sinatra'
require 'sinatra/respond_to'
require 'haml'
require 'json'
require './tracker'

Sinatra::Application.register Sinatra::RespondTo
set :haml, :format => :html5

configure do
  set :port, 1337
end

get "/" do
  redirect '/index'
end
get "/index" do
  @summary = Tracker.summary
  @running = Tracker.running?
  respond_to do |format|
    format.html { haml :index }
    format.json { @summary.to_json }
    format.text { @summary.to_s }
  end
end

get "/history" do
  @history = Tracker.history
  respond_to do |format|
    format.json { @history.to_json}
    format.html { haml :history}
  end
end

#get "/history*", :provides => "html" do
  #"html"
#end

post "/index" do
  status = "false"
  if params[:cmd].eql?('start')
    status = Tracker.start
  elsif params[:cmd].eql?('stop')
    status = Tracker.stop( params[:comment] )
  end
  respond_to do |format|
    format.html { redirect '/' }
    format.json { {:status => status}.to_json }
    format.text { {:status => status}.inspect }
  end
end
