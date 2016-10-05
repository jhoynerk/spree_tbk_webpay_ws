# frozen_string_literal: true
module Tbk::WebpayWSCore
  class Constant

    DELAYED_CAPTURE_PAYMENT_TYPES = {
      'VN' => 'Crédito',  # Credito sin cuotas
      'S2' => 'Crédito',   # Credito sin intereres (2)
      'SI' => 'Crédito',    # Credito sin intereres (3)
      'NC' => 'Crédito'   # Credito sin intereres (N)
    }.freeze

    PAYMENT_TYPES = {
      'VC' => 'Crédito', # Credito cuotas normales (4-48)
      'VD' => 'Débito',  # Debito
    }.merge(DELAYED_CAPTURE_PAYMENT_TYPES).freeze

    INSTALMENT_TYPES = {
      'VN' => 'Sin Cuotas',
      'VC' => 'Cuotas Normales',
      'VD' => 'Venta Debito',
      'SI' => 'Sin Interés',
      'S2' => 'Sin Interés',
      'NC' => 'Sin Interés'
    }.freeze

   TBK_TOKEN = "token_ws"
   TBK_FAILURE_TOKEN = "TBK_TOKEN"

  end
end
