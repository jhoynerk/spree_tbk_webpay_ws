# frozen_string_literal: true
module Tbk::WebpayWSCore
  class MessageSigner
    def self.call(*args)
      new(*args).call
    end

    def initialize(xml, certificate, private_key)
      @xml = Nokogiri::XML(xml)
      @certificate = certificate
      @private_key = private_key
    end

    def call
      envelope = @xml.at_xpath('//env:Envelope')
      envelope.prepend_child(
        %{
          <env:Header>
            <wsse:Security xmlns:wsse='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'
            wsse:mustUnderstand='1'/>
          </env:Header>
        }
      )

      signer.document.xpath("//soapenv:Body", "soapenv" => "http://schemas.xmlsoap.org/soap/envelope/").each do |node|
        signer.digest!(node)
      end

      signer.sign!(issuer_serial: true)
      signed_xml = signer.to_xml

      x509(signed_xml)
    end

    private

    def signer
      if @signer.nil?
        @signer = Signer.new(@xml.to_s)
        @signer.cert = @certificate
        @signer.private_key = @private_key
      end
      @signer
    end

    def x509(signed_xml)
      document = Nokogiri::XML(signed_xml)
      x509data = document.at_xpath("//*[local-name()='X509Data']")
      new_data = x509data.clone
      new_data.set_attribute("xmlns:ds", "http://www.w3.org/2000/09/xmldsig#")
      x509data = document.at_xpath("//*[local-name()='X509Data']")
      new_data = x509data.clone
      new_data.set_attribute("xmlns:ds", "http://www.w3.org/2000/09/xmldsig#")
      n = Nokogiri::XML::Node.new('wsse:SecurityTokenReference', document)
      n.add_child(new_data)
      x509data.add_next_sibling(n)
      document
    end
  end
end
