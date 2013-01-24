module MiniTest
  module AroundTestHooks
    def self.before_test(instance)
      MiniTest::Unit.runner.before_test(instance.class, instance.__name__)
    end

    def self.after_test(instance)
      # MiniTest < 4.1.0 sends #record after all teardown hooks, so don't call
      # #after_test here.
      if MiniTest::Unit::VERSION > "4.1.0"
        MiniTest::Unit.runner.after_test(instance.class, instance.__name__)
      end
    end

    def before_setup
      AroundTestHooks.before_test(self)
      super
    end

    def after_teardown
      super
      AroundTestHooks.after_test(self)
    end
  end
end
