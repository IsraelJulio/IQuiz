class CreateCardAttempts < ActiveRecord::Migration[7.2]
  def change
    create_table :card_attempts do |t|
      t.references :user,         null: false, foreign_key: true
      t.references :card,         null: false, foreign_key: true
      t.references :game_session, null: false, foreign_key: true
      t.string  :direction, null: false
      t.boolean :correct,   null: false
      t.timestamps
    end

    add_index :card_attempts, %i[user_id card_id direction]
  end
end
