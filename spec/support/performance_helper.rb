module PerformanceHelper
  require 'ruby-prof'

  def start_profiling(measure_mode = RubyProf::PROCESS_TIME)
    @profile = RubyProf::Profile.new(measure_mode: measure_mode)
    @profile.start
  end

  def stop_profiling(profile_name = nil)
    result = @profile.stop
    puts "#{profile_name} Time: #{format('%#.3g', total_time(result))}s"
    unless ENV.fetch('CI', false)
      if profile_name
        outdir = './profiles'
        Dir.mkdir(outdir) unless Dir.exist?(outdir)
        printer = RubyProf::MultiPrinter.new(result)
        printer.print(path: outdir, profile: profile_name)
      end
    end
    result
  end

  def total_time(result)
    result.threads.inject(0) { |time, thread| time + thread.total_time }
  end
end
