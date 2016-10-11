# frozen_string_literal: true
module Tbk::WebpayWSCore
  class Base
    attr_reader :response, :action

    def self.call(*args)
      new(*args).call
    end

    def initialize(*_options)
      certificates_and_key
      @id = SecureRandom.hex(10)
    end

    def call
      if @response.nil?
        request = client.build_request(action, message: payload)
        log_request
        signed_xml = MessageSigner.call(
          request.body,
          @public_certificate,
          @private_key
        )

        begin
          @response = client.call(action) do
            xml signed_xml.to_xml(save_with: 0)
          end
          log_response
        rescue Savon::SOAPFault => error
          log_error error
        end
      end
      @response
    end

    def valid?
      Verifier.call(call)
    end

    def client type = :normal
      if type==:normal
        @client ||= Savon.client(wsdl: WebpayWSConfig::WSDL_NORMAL)
      elsif type == :capture || type == :nullify
        @client ||= Savon.client(wsdl: WebpayWSConfig::WSDL_ANULACION_CAPTURA)
      end
    end

    def response_body
      (@response || call).body
    end

    def details
      response_body
    end

    def details_params
      {
        action.to_s => details.to_json
      }
    end


    private

    def certificates_and_key
      @commerce_code = WebpayWSConfig::COMMERCE_CODE
      @private_key = OpenSSL::PKey::RSA.new(File.read(WebpayWSConfig::CLIENT_PRIVATE_KEY))
      @public_certificate = OpenSSL::X509::Certificate.new(
        File.read(WebpayWSConfig::CLIENT_CERTIFICATE)
      )
    end

    def log_request
      log_info = [
            "webpay",
            "id: #{@id}",
            "action: #{action}",
            "type: request",
            "payload: #{payload}",
          ].join(" | ")
      Rails.logger.info log_info
      tbk_webpay_logger.info log_info
    end

    def log_response
      log_info = [
            "webpay",
            "id: #{@id}",
            "action: #{action}",
            "type: response",
            "payload: #{payload}",
            "response: #{@response.try(:body)}"
          ].join(" | ")
      Rails.logger.info log_info
      tbk_webpay_logger.info log_info
    end

    def log_error error
      Rails.logger.error error
      Rails.logger.debug error.backtrace.join("\n")
    end

    def tbk_webpay_logger
      log_name = "tbk_webpay_#{Time.zone.now.strftime("%Y%m%d")}"
      begin
        MultiLogger.add_logger(log_name)
      rescue Exception => e
        Rails.logger.info("Logger #{log_name} already initialized")
      end
      return Rails.logger.send(log_name)
    end

    def payload
      raise "You need to redefine this method"
    end

  end
end
