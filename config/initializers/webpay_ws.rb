module WebpayWSConfig
  CONFIG = YAML.load_file(Rails.root.join("config/tbk-webpay-ws.yml"))[Rails.env]

  COMMERCE_CODE = CONFIG['webpay_commerce_code']
  CLIENT_CERTIFICATE = CONFIG['webpay_client_certificate']
  CLIENT_PRIVATE_KEY = CONFIG['webpay_client_private_key']
  TBK_CERTIFICATE = CONFIG['webpay_tbk_certificate']
  WSDL_NORMAL = CONFIG['webpay_normal_wsdl']
  WSDL_ANULACION_CAPTURA = CONFIG['webpay_anulacion_captura_wsdl']

end