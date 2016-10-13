module WebpayWSConfig
  CONFIG = YAML.load(ERB.new(File.read(Rails.root.join("config/tbk-webpay-ws.yml"))).result)[Rails.env]

  COMMERCE_CODE = CONFIG['webpay_commerce_code']
  CLIENT_CERTIFICATE = CONFIG['webpay_client_certificate']
  CLIENT_PRIVATE_KEY = CONFIG['webpay_client_private_key']
  TBK_CERTIFICATE = CONFIG['webpay_tbk_certificate']
  WSDL_NORMAL = CONFIG['webpay_normal_wsdl']

  WSDL_ANULACION_CAPTURA = CONFIG['webpay_anulacion_captura_wsdl']
  CAPTURE_TIME = CONFIG['webpay_days_to_capture'].present? ? CONFIG['webpay_days_to_capture'].to_i : nil

  # Constant used for select mode of capture (instantly/delayed)
  DELAY_CAPTURE_MODE = WSDL_ANULACION_CAPTURA.present? && CAPTURE_TIME.present?
end