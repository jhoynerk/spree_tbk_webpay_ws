# frozen_string_literal: true
module Tbk::WebpayWSCore
  class Transaction < Base
    attr_reader :amount, :order_number, :session_id, :commerce_code, :return_url, :final_url

    def initialize(amount, order_number, session_id, return_url, final_url)
      super
      @amount = amount
      @order_number = order_number
      @session_id = session_id
      @return_url = return_url
      @final_url = final_url
      @action = :init_transaction
    end

    def token
      response_body[:token]
    end

    def url
      response_body[:url]
    end

    def response_body
      super[:init_transaction_response][:return]
    end

    def  details_params
      details = payload
      details['wsInitTransactionInput'].merge!("response" => response_body)
      details['wsInitTransactionInput'] = details['wsInitTransactionInput'].to_json
      details.merge(Constant::TBK_TOKEN =>  token)
    end

    private

    def payload
      {
        'wsInitTransactionInput' => {
          'wSTransactionType' => 'TR_NORMAL_WS',
          'buyOrder' => order_number,
          'sessionId' => session_id,
          'returnURL' =>  return_url,
          'finalURL' =>  final_url,
          'transactionDetails' => {
            'amount' => amount,
            'commerceCode' => commerce_code,
            'buyOrder' => order_number
          }
        }
      }
    end

  end
end
