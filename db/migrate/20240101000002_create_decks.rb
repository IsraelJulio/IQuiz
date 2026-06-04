class CreateDecks < ActiveRecord::Migration[7.2]
  def change
    create_table :decks do |t|
      t.string   :name,        null: false
      t.text     :description
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :decks, :deleted_at
  end
end
