# frozen_string_literal: true
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

    def response_body
      ''
    end

  end
end
