class AddHstoreExtension < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.adapter_name.downcase == 'postgresql'
      execute 'CREATE EXTENSION IF NOT EXISTS hstore'
    end
  end

  def down
    if ActiveRecord::Base.connection.adapter_name.downcase == 'postgresql'
      execute 'DROP EXTENSION hstore'
    end
  end
end
