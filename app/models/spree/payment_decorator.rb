module Spree
  Payment.class_eval do
    scope :from_webpay_ws, -> { joins(:payment_method).where(spree_payment_methods: {type: Spree::Gateway::WebpayWS.to_s}) }

    after_initialize :set_webpay_ws_trx_id

    def webpay_ws?
      self.payment_method.type == Spree::Gateway::WebpayWS.to_s
    end

    def webpay_ws_quota_type
      payment_type = webpay_params_values("get_transaction_result")
      Tbk::WebpayWSCore::Constant::INSTALMENT_TYPES[payment_type["payment_type_code"]] || payment_type
    end

    def webpay_ws_payment_type
      payment_type = webpay_params_values("get_transaction_result")
      Tbk::WebpayWSCore::Constant::PAYMENT_TYPES[payment_type["payment_type_code"]] || payment_type
    end

    def webpay_params_values key
      begin
        webpay_params[key] ? JSON.parse(webpay_params[key]) : {}
      rescue JSON::ParserError => error
        Rails.logger.error error
        return {}
      end
    end

    private
      # Public: Setea un trx_id unico.
      #
      # Returns Token.
      def set_webpay_ws_trx_id
        self.webpay_trx_id ||= generate_webpay_trx_id
      end

      # Public: Genera el trx_id unico.
      #
      # Returns generated trx_id.
      def generate_webpay_ws_trx_id
        Digest::MD5.hexdigest("#{self.order.number}#{self.order.payments.count}")
      end
  end
end
