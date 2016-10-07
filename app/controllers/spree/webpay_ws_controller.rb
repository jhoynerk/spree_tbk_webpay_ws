module Spree
  class WebpayWsController < StoreController

    skip_before_filter :verify_authenticity_token
    helper 'spree/checkout'

    before_filter :load_data, :only => [:confirmation, :success, :failure]

    def pay
        @order = current_order || raise(ActiveRecord::RecordNotFound)
        @payment = @order.payments.order(:id).last
        payment_method = @payment.payment_method
        provider = payment_method.provider.new

        trx_id     = @payment.webpay_trx_id
        amount  = @order.webpay_ws_amount
         webpay_init_transaction = provider.init_transaction amount, @order.number,trx_id, webpay_ws_confirmation_url, webpay_ws_success_url

         if webpay_init_transaction.valid?
          @payment.update_attributes(webpay_params: webpay_init_transaction.details_params)
          response = Net::HTTP.post_form(URI(webpay_init_transaction.url), token_ws: webpay_init_transaction.token)

           if response.code.to_i == 200
              respond_to do |format|
                format.html { render text: response.body.html_safe }
              end
            end

        end
    end

    def confirmation
      begin
        token_tbk = @payment.webpay_ws_token
        provider = @payment_method.provider.new

        webpay_results = provider.confirmation token_tbk

        if webpay_results
          unless ['failed', 'invalid'].include?(@payment.state)
            response_ack =  provider.response_ack token_tbk
            # If ACK is OK
            if response_ack && response_ack.http.code.to_i == 200
              @payment.update_attributes(webpay_params: @payment.webpay_params.merge(webpay_results.details_params), accepted: true)
              Rails.logger.info "payment_state:#{@payment.state} || payment_accepted:#{@payment.accepted} || order_state:#{@order.state}" if @payment && @order
              WebpayWorker.perform_async(@payment.id, "accepted")

              response = Net::HTTP.post_form(URI(webpay_results.url), token_ws: token_tbk)
              if response.code.to_i == 200
                respond_to do |format|
                  format.html { render text: response.body.html_safe }
                end
                return
              end

            end

          end
        end
        redirect_to webpay_ws_failure_path(params), alert: I18n.t('payment.transaction_error')
      rescue
        @payment.started_processing!
        @payment.failure!
         redirect_to webpay_ws_failure_path(params), alert: I18n.t('payment.transaction_error')
      end
    end

    def success
      # To clean the Cart
      session[:order_id] = nil
      @current_order     = nil

      redirect_to root_path and return if @payment.blank?

      Rails.logger.info "payment_state:#{@payment.state} || payment_accepted:#{@payment.accepted} || order_state:#{@order.state}" if @payment && @order
      Rails.logger.info "[WebpayController : Success] - Order: #{@order.number}" if @order

      if @payment.failed? || !@payment.accepted
        # reviso si el pago esta fallido y lo envio a la vista correcta
        redirect_to webpay_ws_failure_path(params) and return
      else
        if @order.completed? || @payment.accepted
          flash.notice = Spree.t(:order_processed_successfully)
          redirect_to completion_route and return
        else
          redirect_to webpay_ws_failure_path(params) and return
        end

      end
    end

    # GET spree/webpay/failure
    def failure
    end

    private
      def load_data
        token_params = params[Tbk::WebpayWSCore::Constant::TBK_TOKEN] ||  params[Tbk::WebpayWSCore::Constant::TBK_FAILURE_TOKEN]
        @payment = Spree::Payment.by_webpay_ws_token(token_params)

        unless @payment.blank?
          @payment_method = @payment.payment_method
          @order          = @payment.order
        end
      end

      # Same as CheckoutController#completion_route
      def completion_route
        spree.order_path(@order)
      end
  end
end
