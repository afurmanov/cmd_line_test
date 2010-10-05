require 'rubygems'
require 'shoulda'
require File.dirname(__FILE__) + '/../test'

class CliShouldaSpecificTest < Test::Unit::TestCase
  run_command_line_as {CliApp.run}
  
  context "outer" do
    run_with_argv "--option", "OUTER" do 
      assert_out_contains /OUTER/
    end
    context "inner" do
      run_with_argv "--option", "INNER" do 
        assert_out_contains /INNER/
      end
    end
  end
end


