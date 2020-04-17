class AddProviderToTask < ActiveRecord::Migration[6.0]
  def change
    add_reference :tasks, :provider, foreign_key: { to_table: :users }
  end
end
