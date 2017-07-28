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
        @payment.update_attributes(webpay_params: webpay_init_transaction.details_params, webpay_token: webpay_init_transaction.token)
        response = Net::HTTP.post_form(URI(webpay_init_transaction.url), token_ws: webpay_init_transaction.token)

        if response.code.to_i == 200
          respond_to do |format|
            format.html { render text: response.body.html_safe }
          end
          return
        end
      end
      redirect_to webpay_ws_failure_path({order_number: @order.number}), alert: I18n.t('payment.transaction_error')
    end

    def confirmation
      begin
        if @order.completed?
          redirect_to completion_route and return
        end

        token_tbk = @payment.webpay_ws_token
        provider = @payment_method.provider.new

        webpay_results = provider.confirmation token_tbk

        if webpay_results
          unless ['failed', 'invalid'].include?(@payment.state)
            @payment.update_attributes(webpay_params: @payment.webpay_params.merge(webpay_results.details_params))
            response_ack =  provider.response_ack(token_tbk)

            if response_ack  # If ACK is OK
              @payment.update_attributes(webpay_params: @payment.webpay_params.merge(response_ack.details_params), accepted: true)
              Rails.logger.info "payment_state:#{@payment.state} || payment_accepted:#{@payment.accepted} || order_state:#{@order.state}" if @payment && @order
              WebpayOrderCompleterService.new(@payment.id, true).complete

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
      rescue Exception => e
        Rails.logger.error "Error in Payment #{@payment.id} - #{@payment.order.number}"
        Rails.logger.error e

        WebpayOrderCompleterService.new(@payment.id, false).complete

        redirect_to webpay_ws_failure_path(params), alert: I18n.t('payment.transaction_error') and return
      end
      redirect_to webpay_ws_failure_path(params.merge(rejected: true)), alert: I18n.t('payment.transaction_error')
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
      @rejected = params[:rejected]=="true"
    end

    private
    def load_data
      token_params = params[Tbk::WebpayWSCore::Constant::TBK_TOKEN] ||  params[Tbk::WebpayWSCore::Constant::TBK_FAILURE_TOKEN]
      @payment = Spree::Payment.by_webpay_ws_token(token_params)

      if @payment.present?
        @payment_method = @payment.payment_method
        @order          = @payment.order
      else
        @order = Spree::Order.find_by number: params[:order_number]
        @payment = @order.payments.order(:id).last if @order
      end
    end

    # Same as CheckoutController#completion_route
    def completion_route
      spree.order_path(@order)
    end
  end
end
