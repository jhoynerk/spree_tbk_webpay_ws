# frozen_string_literal: true
module Tbk::WebpayWSCore
  class Capture < Base
    def initialize(authorization_code, order_number, capture_amount)
      super
      @authorization_code = authorization_code
      @capture_amount = capture_amount
      @order_number = order_number
      @action = :capture
    end

    def client
      super(:capture)
    end

    def token
      response_body[:token]
    end

    def captured_amount
      response_body[:captured_amount]
    end


    def authorization_date
      response_body[:authorization_date].to_datetime
    end

    def response_body
      super[:capture_response][:return]
    end


    private

    def payload
      {
        "captureInput" =>
        {
          "commerceId" =>  @commerce_code,
          "buyOrder" => @order_number,
          "authorizationCode" => @authorization_code,
          "captureAmount" => @capture_amount
        }
      }
    end

  end
end
