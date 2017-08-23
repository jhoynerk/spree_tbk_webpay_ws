module Spree
  Order.class_eval do
    # Se re-define cuales son pagos pendientes
    def pending_payments
      payments.select{ |payment| payment.checkout? or payment.completed? }
    end

    # Step only visible when payment failure

    insert_checkout_step :webpay_ws, :after => :payment, if: Proc.new {|order| order.has_webpay_ws_payment_method? or order.state == Spree::Gateway::WebpayWS.STATE}
    remove_transition from: :payment, to: :complete,  if: Proc.new {|order| order.has_webpay_ws_payment_method? or order.state == Spree::Gateway::WebpayWS.STATE}


    # Indica si la orden tiene algun pago con Webpay completado con exito
    #
    # Return TrueClass||FalseClass instance
    def webpay_ws_payment_completed?
      if payments.completed.from_webpay_ws.any?
        true
      else
        false
      end
    end

    def webpay_ws_client_name
      if ship_address
        ship_address.full_name
      end
    end

    # Indica si la orden tiene asociado un pago por Webpay
    #
    # Return TrueClass||FalseClass instance
    def has_webpay_ws_payment_method?
      payments.valid.from_webpay_ws.any?
    end

    # Devuelvela forma de pago asociada a la order, se extrae desde el ultimo payment
    #
    # Return Spree::PaymentMethod||NilClass instance
    def webpay_ws_payment_method
      has_webpay_ws_payment_method? ? payments.valid.from_webpay_ws.order(:id).last.payment_method : nil
    end

    # Entrega en valor total en un formato compatible con el estandar de Webpay
    #
    # Return String instance
    def webpay_ws_amount
      # TODO - Ver que pasa cuando hay decimales
      total.to_i
    end
  end
end