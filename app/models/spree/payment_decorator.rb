module Spree
  Payment.class_eval do
    scope :from_webpay_ws, -> { joins(:payment_method).where(spree_payment_methods: {type: Spree::Gateway::WebpayWS.to_s}) }
    scope :webpay_ws_captured,  -> { from_webpay_ws.where(webpay_ws_captured: true).completed }
    scope :webpay_ws_uncaptured,  -> { from_webpay_ws.where(webpay_ws_captured: [false, nil]).completed }

    after_initialize :set_webpay_ws_trx_id

    def self.by_webpay_ws_token token
      self.find_by("webpay_params -> '#{Tbk::WebpayWSCore::Constant::TBK_TOKEN}' = ?", token)
    end

    def webpay_ws?
      self.payment_method.type == Spree::Gateway::WebpayWS.to_s
    end

    def webpay_ws_transaction_params
      webpay_params_values("get_transaction_result")
    end

    def webpay_ws_quota_type
      Tbk::WebpayWSCore::Constant::INSTALMENT_TYPES[webpay_ws_payment_type_code] if webpay_ws_transaction_params.present?
    end

    def webpay_ws_payment_type
      Tbk::WebpayWSCore::Constant::PAYMENT_TYPES[webpay_ws_payment_type_code] if webpay_ws_transaction_params.present?
    end

    def webpay_ws_payment_type_code
      webpay_ws_transaction_params["detail_output"]["payment_type_code"] if webpay_ws_transaction_params.present?
    end

    def webpay_ws_authorization_code
      webpay_ws_transaction_params["detail_output"]["authorization_code"] if webpay_ws_transaction_params.present?
    end

    def webpay_ws_authorization_amount
      webpay_ws_transaction_params["detail_output"]["amount"].to_i if webpay_ws_transaction_params.present?
    end

   def webpay_ws_card_number
      webpay_ws_transaction_params["card_detail"]["card_number"] if webpay_ws_transaction_params.present?
    end

    def webpay_ws_shares_number
      webpay_ws_transaction_params["detail_output"]["shares_number"] if webpay_ws_transaction_params.present?
    end

    def webpay_ws_transaction_date
      webpay_ws_transaction_params["transaction_date"] if webpay_ws_transaction_params.present?
    end

    def webpay_ws_token
      webpay_params[Tbk::WebpayWSCore::Constant::TBK_TOKEN]
    end

    def webpay_params_values key
      begin
        webpay_params[key] ? JSON.parse(webpay_params[key]) : {}
      rescue JSON::ParserError => error
        Rails.logger.error error
        return {}
      end
    end

    # Capture a specified amount from a webpay delayed capture
    def capture_webpay_ws cap_amount = nil
      amount_to_capture =  cap_amount || webpay_ws_authorization_amount.to_s
      if can_capture_webpay_ws?(amount_to_capture)
        provider = payment_method.provider.new
        provider.webpay_capture webpay_ws_authorization_code, order.number, amount_to_capture, self.id
      end
    end

    # Determine if payment is  able to capture a webpay ws capture from a credit transaction
    def can_capture_webpay_ws? amount_to_capture
      return false unless WebpayWSConfig::DELAY_CAPTURE_MODE

      if webpay_ws? && completed? && !webpay_ws_captured
        if webpay_ws_capturable?
          if amount_to_capture.to_i <=  amount.to_i && amount_to_capture.to_i != 0
            true
          else
            Rails.logger.info "Can't capture payment #{id}. Amount #{amount_to_capture} is not a valid amount"
          end
        else
          Rails.logger.info "Can't capture payment #{id}. Payment type #{webpay_ws_payment_type_code} is not permited"
        end
      else
        Rails.logger.info "Can't capture payment #{id}. Error in validation: webpay_ws?=#{webpay_ws?} | completed?=#{completed?} | !webpay_ws_captured=#{!webpay_ws_captured}"
        false
      end
    end

    def webpay_ws_capturable?
      Tbk::WebpayWSCore::Constant::DELAYED_CAPTURE_PAYMENT_TYPES.keys.include?(webpay_ws_payment_type_code)
    end

    private
      # Public: Setea un trx_id unico.
      #
      # Returns Token.
      def set_webpay_ws_trx_id
        self.webpay_trx_id ||= generate_webpay_ws_trx_id
      end

      # Public: Genera el trx_id unico.
      #
      # Returns generated trx_id.
      def generate_webpay_ws_trx_id
        Digest::MD5.hexdigest("#{self.order.number}#{self.order.payments.count}")
      end
  end
end
