module Redcar
  # Cribbed from ruby-processing. Many thanks!
  class Runner
    # Trade in this Ruby instance for a JRuby instance, loading in a 
    # starter script and passing it some arguments.
    # If --jruby is passed, use the installed version of jruby, instead of 
    # our vendored jarred one (useful for gems).
    def spin_up
      bin = "#{File.dirname(__FILE__)}/../../bin/redcar"
      jruby_complete = File.expand_path(File.join(File.dirname(__FILE__), "..", "jruby-complete-1.5.2.jar"))
      unless File.exist?(jruby_complete)
        puts "\nCan't find jruby jar at #{jruby_complete}, did you run 'redcar install' ?"
        exit 1
      end
      ENV['RUBYOPT'] = nil # disable other native args
      # add -d32 -client for faster startup if the jvm is defaulting to server/64bit mode
      command = "java #{java_args} -Xmx500m -Xss1024k -Djruby.memory.max=500m -Djruby.stack.max=1024k -cp \"#{jruby_complete}\" org.jruby.Main #{"--debug" if debug_mode?} \"#{bin}\" #{cleaned_args} --no-sub-jruby --ignore-stdin"
      puts command
      exec(command)
    end
    
    def cleaned_args
      # We should never pass --fork to a subprocess
      ARGV.find_all {|arg| arg != '--fork'}.map do |arg|
        if arg =~ /--(.+)=(.+)/
          "--" + $1 + "=\"" + $2 + "\""
        else
          arg
        end
      end.join(' ')
    end
    
    def debug_mode?
      ARGV.include?("--debug")
    end
    
    def java_args
      str = ""
      if Config::CONFIG["host_os"] =~ /darwin/
        str <<"-XstartOnFirstThread"
      end
      
      if ARGV.include?("--load-timings")
        str << " -Djruby.debug.loadService.timing=true"
      end
      
      if ARGV.include?("--quick")
        str << " -d32 -client"
      end
      str
    end
  end
end
