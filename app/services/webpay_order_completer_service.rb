class WebpayOrderCompleterService
  attr_reader :payment, :order, :accepted

  def initialize(payment_id, accepted)
    @payment  = Spree::Payment.find(payment_id)
    @order    = @payment.order
    @accepted = accepted
  end

  def complete
    begin
      if @accepted
        capture_payment!
        @order.next unless @order.complete?
      else
        failure_payment!
      end
    rescue Exception => e
      Rails.logger.error("Error al procesar pago orden #{@order.number}: E -> #{e.message}")
    end
  end

  private

  def capture_payment!
    @payment.started_processing!
    @payment.capture!
  end

  def failure_payment!
    @payment.started_processing!
    @payment.failure!
  end

end