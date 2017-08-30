class AddFullNameToRefineryUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :refinery_users, :full_name, :string
  end
end
