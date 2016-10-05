module Tbk::WebpayWSCore
  class ACK < Base
    def initialize(token)
      super
      @token = token
      @action = :acknowledge_transaction
    end

    private

    def payload
      { tokenInput: @token }
    end

  end
end
