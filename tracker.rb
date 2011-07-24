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
      return false unless File.readable? @@data_file
      file = File.new(@@data_file,"r:utf-8")
      today = Array.new
      file.each do |line|
        data = line.chomp.split(",")
        if(data.first == date)
          today << data
        end
      end
      file.close
      return today
    end

    def summary(date=nil)
      if date.nil?
        date = self.date_string
      end
      if day = self.day(date)
        time = 0
        day.each do |d|
          time += (d[2].to_i - d[1].to_i)
        end
        if self.locked?
          time += (Time.now.to_i - self.locked_at?)
        end
        {:worked => time, :worked_hours => time.hours, :work_diff => (time - @@workday), :work_diff_hours => (time - @@workday).hours}
      else
        {:worked => 0, :worked_hours => 0, :work_diff => (0 - @@workday), :work_diff_hours => (0 - @@workday).hours}
      end
    end

    def history
      history = {}
      return false unless File.exists? @@data_file
      file = File.open(@@data_file)
      file.each do |line|
        date, start, stop, comment = line.split(",")
        diff = stop.to_i - start.to_i
        date = date.chomp
        # Pure chaos! Embrace!
        history[:days] = Hash.new unless history[:days].is_a?(Hash)
        history[:days][date] = Hash.new if !history[:days][date].is_a?(Hash)
        history[:days][date][:runs] = Array.new unless history[:days][date][:runs].is_a?(Array)
        history[:days][date][:runs] << {:start => start.to_i, :stop => stop.to_i}
        history[:days][date][:worked] = (history[:days][date][:worked] || 0) + (stop.to_i - start.to_i)
        history[:days][date][:worked_hours] = history[:days][date][:worked].hours
        history[:days][date][:work_diff] = history[:days][date][:worked] - @@workday
        history[:days][date][:work_diff_hours] = history[:days][date][:work_diff].hours
        history[:days][date][:comments] = Array.new unless history[:days][date][:comments].is_a?(Array)
        history[:days][date][:comments] << comment.chomp
      end
      history[:days].each do |day, data|
        history[:total] = (history[:total] || 0) + data[:worked]
        history[:total_hours] = history[:total].hours
        history[:total_diff] = (history[:total_diff] || 0) + data[:work_diff]
        history[:total_diff_hours] = history[:total_diff].hours
      end
      return history
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
      return false unless File.readable? @@lock_file
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
        file.puts("#{self.date_string(start_time)}, #{start_time}, #{end_time}, \"#{comment}\"")
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

