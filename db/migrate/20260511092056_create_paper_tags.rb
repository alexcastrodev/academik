class CreatePaperTags < ActiveRecord::Migration[8.1]
  def change
    create_table :paper_tags do |t|
      t.references :paper, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :paper_tags, %i[paper_id tag_id], unique: true
  end
end
