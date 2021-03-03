class CreateScrapingHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :scraping_histories do |t|
      t.integer :scraping_type
      t.integer :keyword_id
      t.integer :job_id, null: false
      t.integer :status
      t.datetime :start_at, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :end_at
      t.string :note
      t.timestamps
    end
  end
end
