class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string  :name,       null: false
      t.boolean :is_israel,  null: false, default: false
      t.timestamps
    end
  end
end
