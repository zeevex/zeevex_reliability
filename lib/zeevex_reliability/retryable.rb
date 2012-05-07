module ZeevexReliability
  module Retryable
    # Options:
    # * :tries - Number of retries to perform. Defaults to 3.
    # * :on - The Exception on which a retry will be performed.
    #         Defaults to StandardError
    #
    # If the final attempts also receives an exception, that exception
    # will be raised.
    #
    # Example
    # =======
    #   retryable(:tries => 1, :on => OpenURI::HTTPError) do
    #     # your code here
    #   end
    #
    def self.retry(options = {}, &block)
      opts = { :tries => 3, :on => StandardError }.merge(options)

      retry_exception, retries = opts[:on], opts[:tries]

      begin
        return yield
      rescue retry_exception
        if (retries -= 1) > 0
          retry
        else
          raise
        end
      end
    end
  end
  
end

