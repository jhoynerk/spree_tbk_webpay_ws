class AddWebpayTokenToSpreePayment < ActiveRecord::Migration
  def change
    add_column :spree_payments, :webpay_token, :string
  end
end
