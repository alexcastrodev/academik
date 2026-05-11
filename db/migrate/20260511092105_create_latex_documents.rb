class CreateLatexDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :latex_documents do |t|
      t.string :title, null: false
      t.text :content
      t.integer :generation_type, null: false, default: 2
      t.string :sourceable_type
      t.bigint :sourceable_id

      t.timestamps
    end

    add_index :latex_documents, %i[sourceable_type sourceable_id]
  end
end
