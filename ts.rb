require 'rubygems'
require 'sinatra'
require 'haml'
require 'json'
require './tracker'

set :haml, :format => :html5

get "/", :provides => "html" do
  @today = Tracker.today
  @summary = Tracker.summary
  @running = Tracker.running?
  haml :index
end

get "/", :provides => "json" do
  Tracker.summary.to_json
end

#get "/history*", :provides => "json" do
  #"json"
#end

#get "/history*", :provides => "html" do
  #"html"
#end

post "/", :provides => ["json", "html", "txt"] do
  status = "false"
  if params[:cmd].eql?('start')
    status = Tracker.start
  elsif params[:cmd].eql?('stop')
    status = Tracker.stop( params[:comment] )
  end
  case request.accept.first
  when "text/html"
    redirect to("/")
  when "application/json"
    status.to_json
  when "text/plain"
    status.to_s
  end
end
