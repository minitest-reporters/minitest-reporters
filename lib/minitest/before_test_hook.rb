module MiniTest
  module BeforeTestHook
    def before_setup
      runner = MiniTest::Unit.runner

      if runner.respond_to?(:before_test)
        runner.before_test(self.class, __name__)
      end

      super
    end
  end
end
