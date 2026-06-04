class CreateAchievements < ActiveRecord::Migration[7.2]
  def change
    create_table :achievements do |t|
      t.string :key,         null: false
      t.string :name,        null: false
      t.text   :description, null: false
      t.string :icon,        null: false, default: "🏆"
      t.timestamps
    end

    add_index :achievements, :key, unique: true
  end
end
