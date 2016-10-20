module Tbk
  module WebpayWS
    class Payment

      # tbk_total_price - integer - Total amount of the purchase. Last two digits are considered decimals.
      # tbk_order_id - string - The purchase order id.
      # session_id - integer - The user session id.
      #
      # Returns a  response of the init transaction was created sucessful
      def init_transaction  tbk_total_price, order_number,session_id, webpay_ws_confirmation_url, webpay_ws_success_url
        WebpayWSCore::Transaction.new(tbk_total_price, order_number,session_id, webpay_ws_confirmation_url, webpay_ws_success_url)
      end

      # Public: Confirmation callback executed from Webpay servers.
      # Checks Webpay transactions workflow.
      #
      # Returns webpay confirmation response if all is OK
      def confirmation token_tbk
        webpay_results = WebpayWSCore::Result.new(token_tbk)

        accepted = true
        unless  webpay_results.valid? && webpay_results.transaction_details[:response_code].to_i == 0 # Valid response
          accepted =  false
          Rails.logger.info "Invalid response for #{ webpay_results.transaction_details[:buy_order]}"
          response_ack token_tbk # response ACK for fail status
        end
        unless order_exists?(webpay_results.transaction_details[:buy_order])
          accepted = false
          Rails.logger.info "Order #{ webpay_results.transaction_details[:buy_order]} not exists"
        end
        if order_paid?(webpay_results.transaction_details[:buy_order])
          accepted = false
          Rails.logger.info "Order #{ webpay_results.transaction_details[:buy_order]} already paid"
        end
        unless  order_right_amount?(webpay_results.transaction_details[:buy_order], webpay_results.transaction_details[:amount].to_i)
          accepted =  false
          Rails.logger.info "Invalid amount of response for  order #{ webpay_results.transaction_details[:buy_order]} and payment amount #{webpay_results.transaction_details[:amount]}"
        end

        if accepted
          return webpay_results
        else
          return nil
        end
      end

      # Response ACK  confirmation before 30 seconds for close transaction
      def response_ack token_tbk
        WebpayWSCore::ACK.call(token_tbk)
      end

      def webpay_capture webpay_ws_authorization_code, order_number, amount_to_capture, payment_id
        payment = Spree::Payment.find payment_id
        capture_ws = Tbk::WebpayWSCore::Capture.new(webpay_ws_authorization_code, order_number, amount_to_capture)
        response = capture_ws.call
        begin
            if response.http.code.to_i == 200 && capture_ws.response_body.present?
              payment.update_attributes(webpay_params: payment.webpay_params.merge(capture_ws.details_params), webpay_ws_captured: true)
              return true
            else
              Rails.logger.info "Payment #{payment_id} can't be captured"
              return false
            end
        rescue Exception => e
          Rails.logger.error e
          false
        end
      end


      private
      # Private: Checks if an order exists and is ready for payment.
      #
      # order_id - integer - The purchase order id.
      #
      # Returns a boolean indicating if the order exists and is ready for payment.
      def order_exists?(order_id)
        order = Spree::Order.find_by(number: order_id)
        if order.blank?
          return false
        else
          return true
        end
      end

      # Private: Checks if an order is already paid.
      #
      # order_id - integer - The purchase order id.
      #
      # Returns a boolean indicating if the order is already paid.
      def order_paid? order_id
        order = Spree::Order.find_by_number(order_id)
        return order.paid? || order.payments.completed.any?
      end

      # Private: Checks if an order has the same amount given by Webpay.
      #
      # order_id - integer - The purchase order id.
      # tbk_total_amount - The total amount of the purchase order given by Webpay.
      #
      # Returns a boolean indicating if the order has the same total amount given by Webpay.
      def order_right_amount? order_id, tbk_total_amount
        order = Spree::Order.find_by_number(order_id)
        if order.blank?
          return false
        else
          return order.webpay_ws_amount == tbk_total_amount
        end
      end

    end
  end
end