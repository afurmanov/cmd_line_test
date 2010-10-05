require File.dirname(__FILE__) + '/test_helper'

class CliUsageTest < Test::Unit::TestCase
  run_command_line_as {CliApp.run}
  
  run_with_argv :name => 'no argv' do
    assert_successful_run
  end
  
  run_and_succeed :name => 'no argv, shorter form'
  
  run_and_succeed "--help" do
    assert_out_contains /Usage:/
  end
  
  run_and_succeed "--option", "PRINT_THIS" do
    assert_out_contains /PRINT_THIS/
  end
  
  run_and_succeed :name => "run_with_argv could be used within block" do
    run_with_argv 
  end

  run_and_fail "--invalid-option", :name => "running with invalid option" do
    exception_raised = false
    begin
      assert_successful_run
    rescue Exception 
      exception_raised = true
    end
    assert(exception_raised)
  end
  
  run_and_fail "--raise", :name => "raise exception" do
    exception_raised = false
    begin
      assert_successful_run
    rescue StandardError => error
      assert error.to_s =~ /CLI exception/
      exception_raised = true
    end
    assert(exception_raised)
  end
end

class CliTestNoCommandLineDefined < Test::Unit::TestCase
  def test_failure_when_command_line_defined
    assert_raise(RuntimeError) {self.class.run_with_argv}
  end
end

class CliTestShowOutput < Test::Unit::TestCase
  
  run_command_line_as(:show_output => true) {CliApp.run}

  @@captured_out = ""
  @@original_stdout = $stdout
  @@string_out = StringIO.new(@@captured_out)
  $stdout = @@string_out
  run_and_succeed "--help" do
    $stdout.flush
    $stdout = @@original_stdout
    assert_match /Usage:/, @@captured_out
  end
end
