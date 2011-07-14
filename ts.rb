require 'sinatra'
require 'haml'
require './tracker'

def stop_tracking
  Tracker.stop_tracking( Time.now.to_i )
end

def start_tracking
  Tracker.start_tracking( Time.now.to_i )
end

def set_total
  @t = if params[:t]
         d = params[:t].split("_")
        Time.new( d[0], d[1], d[2] )
      else
        Time.now
      end
  @total = Tracker.total_for @t
end

before do
  @days = Tracker.other_days
end
get '/' do
  set_total
  haml :index
end

post '/' do
  if @params[:cmd].eql?('start')
    @msg = start_tracking
  elsif @params[:cmd].eql?('stop')
    @msg = stop_tracking
  end
  set_total
  haml :index
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
  ="#{@t.year}/#{@t.month}/#{@t.day}"
  ="( #{@total} )"
%form{:method=>"post"}
  %input{:type=>"submit", :name=>"start", :value=>"start"}
  %input{:type=>"submit", :name=>"stop", :value=>"stop"}

%ul
-@days.each do |d|
  %li
    ="<a href='/?t=#{d.gsub('.txt','').gsub('data/','')}'>#{d.gsub('.txt','')}</a>"

