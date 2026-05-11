class CreateAnnotations < ActiveRecord::Migration[8.1]
  def change
    create_table :annotations do |t|
      t.references :paper, null: false, foreign_key: true
      t.integer :page
      t.integer :start_offset
      t.integer :end_offset
      t.text :selected_text
      t.string :color
      t.text :note

      t.timestamps
    end
  end
end
