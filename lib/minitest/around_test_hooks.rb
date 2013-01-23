module MiniTest
  module AroundTestHooks
    def self.included(base)
      base.instance_eval do
        alias_method :run_without_hooks, :run
        alias_method :run, :run_with_hooks
      end
    end

    def run_with_hooks(runner)
      runner.before_test(self.class, self.__name__)
      run_without_hooks(runner)
    ensure
      runner.after_test(self.class, self.__name__)
    end
  end
end
