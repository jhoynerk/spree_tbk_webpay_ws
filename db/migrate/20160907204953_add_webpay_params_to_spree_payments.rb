class AddWebpayParamsToSpreePayments < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.adapter_name.downcase == 'postgresql'
      add_column(:spree_payments, :webpay_params, :hstore) unless column_exists?(:spree_payments, :webpay_params)
    else
      add_column(:spree_payments, :webpay_params, :text) unless column_exists?(:spree_payments, :webpay_params)
    end
  end

  def down
    remove_column :spree_payments, :webpay_params
  end
end
