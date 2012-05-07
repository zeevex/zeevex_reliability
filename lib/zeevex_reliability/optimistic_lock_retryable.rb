module ZeevexReliability
  module OptimisticLockRetryable
    def self.included(base)
      require 'active_record'
      require 'active_record/base'
      base.class_eval do
        include InstanceMethods
      end
    end

    module InstanceMethods
      # Options:
      # * :tries - Number of retries to perform. Defaults to 3.
      #
      # If the final attempts also receives an exception, that exception
      # will be raised.
      #
      # Example
      # =======
      #   model.with_optimistic_retry(:tries => 5) do
      #     # your model frobbing code here
      #     model.save!
      #   end
      #
      def with_optimistic_retry(options = {}, &block)
        opts = { :tries => 3 }.merge(options)
        retries = opts[:tries]

        # a retry may reload the object, so log a message that this
        # may be used incorrectly
        if changed?
          logger.warn "WARNING: with_optimistic_retry called on changed object; if the save fails, changes will be lost!"
        end

        begin
          return yield
        rescue ActiveRecord::StaleObjectError
          if (retries -= 1) > 0
            self.reload
            retry
          else
            raise
          end
        end
      end
    end
    
  end
end

