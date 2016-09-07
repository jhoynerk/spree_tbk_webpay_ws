module Spree
  CheckoutController.class_eval do
      before_filter :check_webpay_ws, only: :edit

      private
      def check_webpay_ws
          redirect_to webpay_ws_path(params) and return if  params[:state] == Spree::Gateway::WebpayWS.STATE and @order.state == Spree::Gateway::WebpayWS.STATE
      end

  end
end
