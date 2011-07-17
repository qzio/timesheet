# Not good to pollute the global classes
# But supersexy code!
class Fixnum
  def hours
    return sprintf("%.2f", self.to_f/60/60).to_f
  end
end

class Tracker

  # Time lock
  @@lock_file = "data/clock.lock"

  # Database
  @@data_file = "data/timetracker.db"

  # Workday in seconds
  @@workday = 28800

  class << self

    def stop(comment="")
      self.write_tracked_time(comment)
      return self.unlock_clock if self.locked?
      return false
    end

    def start
      return self.lock_clock unless self.locked?
      return false
    end

    def today
      return self.day(self.date_today)
    end

    def running?
      return self.locked?
    end

    def day(date)
      file = File.open(@@data_file)
      today = Array.new
      file.each do |line|
        data_array = line.chomp.split(",")
        if(data_array.first.chomp == date)
          today << data_array
        end
        if(data_array.first.chomp != date)
          break
        end
      end
      file.close
      return today
    end

    def summary(date=nil)
      if date.nil?
        date = self.date_today
      end
      day = self.day(date)
      time = 0
      day.each do |d|
        time += (d[2].to_i - d[1].to_i)
      end
      return {:worked => time, :worked_hours => time.hours, :work_diff => (time - @@workday), :work_diff_hours => (time - @@workday).hours}
    end

    def last_line
      #last_line=""
      #return last_line unless File.readable? self.file_name
      #File.open( self.file_name, 'r' ).each_line do |line|
        #last_line = line
      #end
      #last_line
      return "start:1310892473"
    end

    def total_for t
      #file = self.file_name t
      #return 0 unless File.readable? file

      #total = started = stopped = 0
      #File.open( file, 'r' ).each_line do |line|
        #s = line.split ":"
        #if s.first.eql?("stop")
          #if started > 0
            #st = s[1].chomp.to_i
            #total += (st - started)
          #else
          #end
          #started = 0
        #else
          #started = s[1].chomp
          #started = started.to_i
        #end
      #end
      #min  = 60
      #hour = (60*min)
      #hours = total / hour
      #mins = ( total - (hours * hour) ) / min
      #"#{hours} hours and #{mins} mins (#{total}) seconds"
      "2 hours and 23 mins (2333 s)"
    end

    def other_days
      #d = []
      #Dir.glob("data/*txt").each do |day|
        #d << day.gsub('.txt','').gsub('data/','')
      #end
      #d
      return []
    end


  protected 

    def lock_clock
      if locked?
        return false
      else
        lock = File.new(@@lock_file, "w")
        lock.puts Time.now.to_i
        lock.close
        return true
      end   
    end

    def unlock_clock
      if locked?
        File.delete(@@lock_file)
        return true
      end
      return false
    end

    def locked?
      return File.exists?(@@lock_file);
    end

    def locked_at?
      file = File.open(@@lock_file);
      lock_time = file.readline
      file.close
      return lock_time.to_i
    end

    def last_entry
      if File.exists?(@@data_file)
        file = File.open(@@data_file, "r")
        if entry = file.gets
          file.close
          return entry.split(",")
        end
      else
        return false
      end
    end

    def write_tracked_time(comment="")
      if self.locked?
        last_entry = self.last_entry
        start_time = self.locked_at?
        file = File.new(@@data_file, "a+")
        end_time = Time.now.to_i
        work_time = end_time - start_time
        file.puts("#{self.date_today}, #{start_time}, #{end_time}, #{comment}")
        file.close
        return true
      end
      return false
    end

    def date_today
      return Time.new.strftime("%Y-%m-%d")
    end

  end
end

