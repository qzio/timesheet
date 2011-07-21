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
    format.text { @summary.inspect }
    format.txt { @summary.inspect }
  end
end

get "/history" do
  @history = Tracker.history
  respond_to do |format|
    format.json { @history.to_json}
    format.html { haml :history}
    format.text { @history.inspect }
    format.txt { @history.inspect }
  end
end

post "/index" do
  status = "false"
  if params[:cmd].eql?('start')
    error = "Already running" if Tracker.running?
    status = Tracker.start
  elsif params[:cmd].eql?('stop')
    error = "Not started" unless Tracker.running?
    status = Tracker.stop( params[:comment] )
  end
  status = status ? "ok" : "error"
  response = { :status => status }
  response[:error] = error if error
  respond_to do |format|
    format.html { redirect '/' }
    format.json { response.to_json }
    format.text { response.inspect }
  end
end
