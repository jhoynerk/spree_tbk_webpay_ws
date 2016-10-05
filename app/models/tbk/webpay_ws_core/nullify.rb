# frozen_string_literal: true
module Tbk::WebpayWSCore
  class Nullify < Base
    def initialize(authorization_code, order_number, authorized_amount, nullify_amount)
      super
      @authorization_code = authorization_code
      @authorized_amount = authorized_amount
      @order_number = order_number
      @nullify_amount = nullify_amount
      @action = :nullify
    end

    def client
      super(:nullify)
    end

    private

    def payload
      {
        "nullificationInput" =>
        {
          "commerceId" =>  @commerce_code,
          "buyOrder" => @order_number,
          "authorizedAmount" => @authorized_amount,
          "authorizationCode" => @authorization_code,
          "nullifyAmount" => @nullify_amount
        }
      }
    end

  end
end
