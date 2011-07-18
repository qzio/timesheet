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
      return self.day(self.date_string)
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
        date = self.date_string
      end
      day = self.day(date)
      time = 0
      day.each do |d|
        time += (d[2].to_i - d[1].to_i)
      end
      return {:worked => time, :worked_hours => time.hours, :work_diff => (time - @@workday), :work_diff_hours => (time - @@workday).hours}
    end

  protected 

    def lock_clock
      if locked?
        return false
      else
        lock = File.new(@@lock_file, "w:utf-8")
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
        file = File.open(@@data_file)
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
        file = File.new(@@data_file, "a+:utf-8")
        end_time = Time.now.to_i
        work_time = end_time - start_time
        file.puts("#{self.date_string(start_time)}, #{start_time}, #{end_time}, #{comment}")
        file.close
        return true
      end
      return false
    end

    def date_string(time=nil)
      format="%Y-%m-%d"
      if time.nil?
        return Time.new.strftime(format)
      else
        return Time.at(time).strftime(format)
      end
    end

  end
end

