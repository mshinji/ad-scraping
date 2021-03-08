class RemoveStatusFromAds < ActiveRecord::Migration[6.1]
  def up
    remove_column :ads, :status, :integer
  end

  def down
    create_column :ads, :status, :integer
  end
end
