require "active_support/testing/setup_and_teardown"

module ActiveSupport
  module Testing
    module SetupAndTeardown
      module ForMinitest
        remove_method :run

        def before_setup
          super
          run_callbacks :setup
        end

        def after_teardown
          run_callbacks :teardown
          super
        end
      end
    end
  end
end
