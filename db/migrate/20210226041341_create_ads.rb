class CreateAds < ActiveRecord::Migration[6.1]
  def change
    create_table :ads do |t|
      t.string :name
      t.string :url, null: false
      t.integer :engine, null: false
      t.integer :status, default: 0
      t.integer :keyword_id, null: false
      t.integer :job_id, null: false

      t.timestamps
    end
  end
end
