class CreateGoals < ActiveRecord::Migration[7.2]
  def change
    create_table :goals do |t|
      t.references :user, null: false, foreign_key: true
      t.references :deck, null: true,  foreign_key: true
      t.decimal    :target_percentage, null: false, precision: 5, scale: 2
      t.string     :label
      t.timestamps
    end
  end
end
