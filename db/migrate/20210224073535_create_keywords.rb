class CreateKeywords < ActiveRecord::Migration[6.1]
  def change
    create_table :keywords do |t|
      t.string :name, null: false
      t.boolean :available, default: true

      t.timestamps
    end
  end
end
