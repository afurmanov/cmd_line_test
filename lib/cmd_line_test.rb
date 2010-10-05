module CmdLineTest
  module ClassMethods
    attr_accessor :cli_exit_status, :cli_output, :cli_error, :cli_error_stack, :cli_block, :show_output
    
    def run_command_line_as(options = nil, &block)
      self.show_output = options && options[:show_output] || false
      self.cli_block = block
    end
  end #ClassMethods
  
  module InstanceMethods
    def run_with_argv(*args)
      with_ARGV_set_to(*args) {execute}
    end
    
    private
    def execute
      self.class.cli_block.call
    end
    
    def with_ARGV_set_to(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      ignore_assignment_to_const_warning { Object.const_set(:ARGV, args) }
      yield args, options
    end

    def ignore_assignment_to_const_warning 
      warnings_option = $-w
      $-w = nil
      begin
        yield
      ensure
        $-w = warnings_option
      end
    end
  end #InstanceMethods
  
  module Macros
    def run_with_argv(*args, &block)
      raise RuntimeError, "Command is not defined: 'run_command_line_as()' must be called first." unless 
        self.cli_block
      options = args.last.is_a?(Hash) ? args.pop : {}
      argv = args
      test_name = options[:name] || "after running with arguments '#{argv.join(', ')}'"
      generate_test test_name do 
        with_ARGV_set_to *argv do
          begin 
            self.class.cli_exit_status = 0
            self.class.cli_error = ""
            self.class.cli_error_stack = ""
            self.class.cli_output = ""
            $test_class = self.class
            #It used to be $stdout = StringIO.new(...), but it does not work well with rdebug
            class <<$stdout
              alias_method :original_write, :write
              def write(*s)
                original_write(s) if $test_class.show_output 
                $test_class.cli_output << s.to_s if $test_class.cli_output
              end
            end
            execute
          rescue SystemExit => exit_error
            self.class.cli_exit_status = exit_error.status
          rescue Exception => error
            self.class.cli_error_stack = error.backtrace.join("\n")
            self.class.cli_error = error.message
          ensure
            class <<$stdout
              remove_method :write, :original_write
            end
          end
          instance_eval(&block)
        end
      end
    end
    
    def run_and_succeed(*args, &block)
      run_with_argv(*args) do
        assert_successful_run
        instance_eval(&block) if block
      end
    end

    def run_and_fail(*args, &block)
      run_with_argv(*args) do
        assert_failed_run
        instance_eval(&block) if block
      end
    end
    
    private
    def generate_test(name, &block)
      if defined? Shoulda 
        should(name, &block)
      else
        test_name = ("test_".concat name).strip.to_sym
        self.send(:define_method, test_name, &block)
      end
    end
  end #Macros
  
  module Assertions
    def assert_successful_run
      expect_message = "Should run successfully, but"
      assert_equal 0, self.class.cli_exit_status, "#{expect_message} exit status is #{self.class.cli_exit_status}"
      assert self.class.cli_error.empty?, "#{expect_message} exception '#{self.class.cli_error}' has been thrown. Exception stack:\n" + self.class.cli_error_stack
    end
    
    def assert_failed_run
      flunk "Expects either thrown error or exit status not 0." if 0 == self.class.cli_exit_status && self.class.cli_error.empty?
    end

    def assert_out_contains regex
      assert_match regex, self.class.cli_output
    end
  end #Assertions
end

module Test 
  module Unit
    class TestCase
      extend CmdLineTest::ClassMethods
      include CmdLineTest::InstanceMethods
      extend CmdLineTest::Macros
      include CmdLineTest::Assertions
    end
  end
end
