# frozen_string_literal: true
module Tbk::WebpayWSCore
  class Verifier
    def self.call(*args)
      new(*args).call
    end

    def initialize(response)
      @response = response
      @document = Nokogiri::XML(@response.to_s, &:noblanks)
      @tbk_certificate = OpenSSL::X509::Certificate.new(
        File.read(WebpayWSConfig::TBK_CERTIFICATE)
      )
    end

    def call
      check_digest && check_signature
    end

    private

    def sign_info
      @signed_info_node ||= @document.at_xpath(
        "/soap:Envelope/soap:Header/wsse:Security/ds:Signature/ds:SignedInfo",
        ds: 'http://www.w3.org/2000/09/xmldsig#',
        wsse: "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd",
        soap: "http://schemas.xmlsoap.org/soap/envelope/"
      )
    end

    def process_ref(node)
      uri = node.attr('URI')
      element = @document.at_xpath(
        "//*[@wsu:Id='" + uri[1..-1] + "']",
        wsu: "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"
      )
      target = canonicalize(element, nil)
      my_digest_value = Base64.encode64(digest(target)).strip
      digest_value = node.at_xpath("//ds:DigestValue", ds: 'http://www.w3.org/2000/09/xmldsig#').text
      my_digest_value == digest_value
    end

    def digest(message)
      OpenSSL::Digest::SHA1.new.reset.digest(message)
    end

    def check_digest
      sign_info.xpath("//ds:Reference", ds: 'http://www.w3.org/2000/09/xmldsig#').each do |node|
        return false if !process_ref(node)
      end
      true
    end

    def check_signature
      signed_info_canon = canonicalize(sign_info, ['soap'])
      signature = @document.at_xpath(
        '//wsse:Security/ds:Signature/ds:SignatureValue',
        ds: 'http://www.w3.org/2000/09/xmldsig#',
        wsse: "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
      ).text
      @tbk_certificate.public_key.verify(
        OpenSSL::Digest::SHA1.new,
        Base64.decode64(signature),
        signed_info_canon
      )
    end

    def canonicalize(node = document, inclusive_namespaces = nil)
      node.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0, inclusive_namespaces, nil)
    end
  end
end
