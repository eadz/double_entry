module DoubleEntry
  class TimeRange::Quarter
    attr_reader :year, :quarter
    attr_reader :start, :finish

    def initialize(options = {})
      @year    = options.fetch(:year)
      @quarter = options.fetch(:quarter)

      date = Time.local(year, quarter * 3,  1)

      @start  = date.beginning_of_quarter
      @finish = date.end_of_quarter
    end

    def self.current
      TimeRange::Quarter.from_time(Time.now)
    end

    def self.from_time(time)
      TimeRange::Quarter.new(
        :year    => time.year,
        :quarter => (time.month / 3.0).ceil
      )
    end

    def ==(other)
      year == other.year && quarter == other.quarter
    end

    # def previous
    #   TimeRange::Quarter.new(:year => year - 1)
    # end

    # def next
    #   TimeRange::Quarter.new(:year => year + 1)
    # end

    def to_s
      "#{year}::Q#{quarter}"
    end
  end
end
