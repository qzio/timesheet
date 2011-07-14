class Tracker

  def self.file_name t = nil
    t = Time.now unless t
    "data/#{t.year}_#{t.month}_#{t.day}.txt"
  end

  def self.stop_tracking timestamp
    if self.running?
      system "echo 'stop:#{timestamp}' >> #{Tracker.file_name}"
      "stoping the clock"
    else
      "clock is already stopped"
    end
  end

  def self.start_tracking timestamp
    unless self.running?
      system "echo 'start:#{timestamp}' >> #{Tracker.file_name}"
      "starting clock"
    else
      "already started"
    end

  end

  def self.running?
    action = self.last_line.split(":").first
    return action.eql? "start"
  end

  def self.last_line
    last_line=""
    return last_line unless File.readable? self.file_name
    File.open( self.file_name, 'r' ).each_line do |line|
      last_line = line
    end
    last_line
  end

  def self.total_for t
    file = self.file_name t
    return 0 unless File.readable? file

    total = started = stopped = 0
    File.open( file, 'r' ).each_line do |line|
      s = line.split ":"
      if s.first.eql?("stop")
        if started > 0
          st = s[1].chomp.to_i
          total += (st - started)
        else
        end
        started = 0
      else
        started = s[1].chomp
        started = started.to_i
      end
    end
    min  = 60
    hour = (60*min)
    hours = total / hour
    mins = ( total - (hours * hour) ) / min
    "#{hours} hours and #{mins} mins (#{total}) seconds"
  end

  def self.other_days
    d = []
    Dir.glob("data/*txt").each do |day|
      d << day.gsub('.txt','').gsub('data/','')
    end
    d
  end

end
