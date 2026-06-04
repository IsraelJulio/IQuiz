class CreateGameSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :game_sessions do |t|
      t.references :user,  null: false, foreign_key: true
      t.references :deck,  null: true,  foreign_key: true
      t.string     :deck_name
      t.string     :game_mode,          null: false
      t.string     :direction,          null: false
      t.string     :status,             null: false, default: "in_progress"
      t.jsonb      :card_order,         null: false, default: []
      t.integer    :current_card_index, null: false, default: 0
      t.decimal    :total_points,       null: false, default: 0, precision: 8, scale: 2
      t.integer    :cards_total,        null: false, default: 0
      t.integer    :cards_correct,      null: false, default: 0
      t.integer    :max_streak,         null: false, default: 0
      t.integer    :current_streak,     null: false, default: 0
      t.boolean    :anti_grind,         null: false, default: false
      t.datetime   :started_at
      t.datetime   :completed_at
      t.timestamps
    end

    add_index :game_sessions, :status
    add_index :game_sessions, :started_at
  end
end
