require 'optparse'

module CliApp
  class CliException < StandardError
  end
  class <<self
    def run
      OptionParser.new do |opts|
        opts.banner = "Usage: cli.rb [options]\nCommand line test app."
        
        opts.on( "--option OPTIONIAL", "run with OPTIONIAL") do |option|
          puts option
        end
        
        opts.on( "--raise", "raise CliException") do
          raise CliException, "CLI exception"
        end
        
        opts.on_tail("-h", "--help", "show help") do
          puts opts
          #exit NB!
        end      
      end.parse!
    end
  end
end


if $0 == __FILE__
  CliApp.run
end
