module MiniTest
  module AroundTestHooks
    def self.before_test(instance)
      MiniTest::Unit.runner.before_test(instance.class, instance.__name__)
    end

    def self.after_test(instance)
      MiniTest::Unit.runner.after_test(instance.class, instance.__name__)
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
