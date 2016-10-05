# frozen_string_literal: true
module Tbk::WebpayWSCore
  class Result < Base
    def initialize(token)
      super
      @token = token
      @action = :get_transaction_result
    end

    def url
      response_body[:url_redirection]
    end

    def card_number
      response_body[:card_detail][:card_number]
    end

    def details
      response_body[:detail_output]
    end

    def transaction_date
      response_body[:transaction_date].to_datetime
    end

    def response_body
      super[:get_transaction_result_response][:return]
    end

    private

    def payload
      { tokenInput: @token }
    end
  end
end
