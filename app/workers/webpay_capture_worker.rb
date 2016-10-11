#### Schedule with your favorite tool for scheduling ###

class WebpayCaptureWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  sidekiq_options :queue => :webpay

  def perform
    Spree::Payment.webpay_ws_uncaptured.where("spree_payments.created_at <= ?", WebpayWSConfig::CAPTURE_TIME.days.ago).each do |payment|
        payment.capture_webpay_ws
    end
  end

end