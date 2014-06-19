module DoubleEntry
  class TimeRange::Year
    attr_reader :year
    attr_reader :start, :finish

    def initialize(options = {})
      @year = options.fetch(:year)

      @start  = Time.local(year,  1,  1)
      @finish = Time.local(year, 12, 31)
    end

    def self.current
      TimeRange::Year.new(:year => Time.now.year)
    end

    def self.from_time(time)
      TimeRange::Year.new(:year => time.year)
    end

    def ==(other)
      year == other.year
    end

    def previous
      TimeRange::Year.new(:year => year - 1)
    end

    def next
      TimeRange::Year.new(:year => year + 1)
    end

    def to_s
      year.to_s
    end
  end
end
