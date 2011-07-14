require 'sinatra'
require 'haml'
require 'json'
require './tracker'

class Time
  def to_s
   "#{self.year}-#{self.month}-#{self.day}" 
  end
end

set :haml, :format => :html5

def set_total
  @t = if params[:t]
        d = params[:t].split("_")
        Time.new( d[0], d[1], d[2] )
      else
        Time.now
      end
  @total = Tracker.total_for @t
  @total_str = "#{@t}:#{@total}"
end

before do
  @days = Tracker.other_days
end

def resp
  @msg ||= "#{request.request_method} #{request.path_info}"
  if request.path_info.eql? '/json'
    content_type :json
    {
      :msg => @msg,
      :total => "#{@total_str}",
      :days => @days.collect{|d| "/json?t=#{d}"}
    }.to_json+"\n"
  elsif request.path_info.eql? '/txt'
    content_type :text
    "#{@msg}\n#{@t}:#{@total_str}\n"
  else
    haml :index
  end
end

['/', '/json', '/txt'].each do |path|
  get path do
    set_total
    resp
  end
end

['/', '/json', '/txt'].each do |path|
  post path do
    if params[:cmd].eql?('start')
      @msg = Tracker.start_tracking Time.now.to_i
    elsif params[:cmd].eql?('stop')
      @msg = Tracker.stop_tracking Time.now.to_i
    end
    set_total
    resp
  end
end


__END__

@@ layout
%html
  %head
    %title ts project
  %body
    =yield

@@ index
%h1
  time sheet
  =@name
.msg
  =@msg
.total
  total time tracked for
  ="#{@t}: ( #{@total} )"
%form{:method=>"post"}
  %input{:type=>"submit", :name=>"cmd", :value=>"start"}
  %input{:type=>"submit", :name=>"cmd", :value=>"stop"}

%ul
-@days.each do |d|
  %li
    ="<a href='/?t=#{d.gsub('.txt','').gsub('data/','')}'>#{d.gsub('.txt','')}</a>"
