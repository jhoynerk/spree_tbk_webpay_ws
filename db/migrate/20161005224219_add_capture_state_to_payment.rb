class AddCaptureStateToPayment < ActiveRecord::Migration
  def change
    add_column :spree_payments, :webpay_ws_captured, :boolean, default: false
  end
end
