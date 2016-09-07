Spree::Core::Engine.routes.draw do
  # URL for start connection with WebpayWS
  get 'webpay_ws', to: 'webpay_ws#pay', as:  :webpay_ws

  # The return URL for confirm transaction
  post 'webpay_ws/confirmation', to: 'webpay_ws#confirmation', as:  :webpay_ws_confirmation

   # The success URL
  post 'webpay_ws/success', to: 'webpay_ws#success',  as:  :webpay_ws_success

  get 'webpay_ws/failure', to: 'webpay_ws#failure',  as:  :webpay_ws_failure
end