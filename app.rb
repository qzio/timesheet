require 'sinatra'
require 'sinatra/base'
require 'sinatra/respond_with'
require 'sinatra/reloader' if development?
require 'haml'
require 'sass'
require 'json'
require './tracker'

class Timesheet < Sinatra::Base

  register Sinatra::RespondWith

  configure :development do
    register Sinatra::Reloader
    enable :logging
  end

  configure :development, :production do
    set :haml, :format => :html5
    set :port, 1337
    set :server, "thin"
    set :sessions, true
  end

  before "*.:format" do
    content_type params[:format]
  end

  get "/" do
    redirect '/index'
  end

  get "/index.?:format?" do
    @summary = Tracker.summary
    @running = Tracker.running?
    respond_to do |format|
      format.html { haml :index }
      format.json { @summary.to_json }
      format.txt { @summary.inspect }
    end
  end

  get "/history.?:format?" do
    @history = Tracker.history
    respond_to do |format|
      format.json { @history.to_json}
      format.html { haml :history}
      format.txt { @history.inspect }
    end
  end

  post "/index.?:format?" do
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
      format.txt { response.inspect }
    end
  end

  get '/master.css', :provides => [:css] do
    respond_to do |format|
      format.css { sass :master  }
    end
 end

 run! if app_file == $0
end
