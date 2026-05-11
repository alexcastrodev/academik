class CreatePapers < ActiveRecord::Migration[8.1]
  def change
    create_table :papers do |t|
      t.string :title, null: false
      t.string :authors
      t.integer :year
      t.string :journal
      t.string :doi
      t.text :abstract
      t.integer :reading_status, null: false, default: 0
      t.integer :rating
      t.text :extracted_text
      t.text :notes

      t.timestamps
    end

    add_index :papers, :doi, unique: true, where: "doi IS NOT NULL"
  end
end
