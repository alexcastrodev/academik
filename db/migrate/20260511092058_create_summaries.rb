class CreateSummaries < ActiveRecord::Migration[8.1]
  def change
    create_table :summaries do |t|
      t.references :paper, null: false, foreign_key: true
      t.string :model_used
      t.text :content
      t.integer :status
      t.datetime :generated_at
      t.integer :token_count

      t.timestamps
    end
  end
end
