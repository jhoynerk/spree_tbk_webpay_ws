require "spec_helper"

describe Spree::WebpayWSController do
  routes { Spree::Core::Engine.routes }

  describe "routing" do
    # The notification URL
    it "routes to #confirmation" do
      post('/spree/webpay_ws/confirmation').should route_to('spree/webpay_ws#confirmation')
    end

    # The success URL
    it "routes to #success" do
      get('/spree/webpay_ws/success').should route_to('spree/webpay_ws#success')
    end

    # The failure URL
    it "routes to #error" do
      get('/spree/webpay_ws/failure').should route_to('spree/webpay_ws#failure')
    end
  end
end
