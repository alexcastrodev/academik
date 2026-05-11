class CreateCollections < ActiveRecord::Migration[8.1]
  def change
    create_table :collections do |t|
      t.string :name, null: false
      t.integer :parent_id
      t.text :description

      t.timestamps
    end

    add_index :collections, :parent_id
  end
end
