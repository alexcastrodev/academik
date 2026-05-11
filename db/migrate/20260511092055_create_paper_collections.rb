class CreatePaperCollections < ActiveRecord::Migration[8.1]
  def change
    create_table :paper_collections do |t|
      t.references :paper, null: false, foreign_key: true
      t.references :collection, null: false, foreign_key: true

      t.timestamps
    end

    add_index :paper_collections, %i[paper_id collection_id], unique: true
  end
end
