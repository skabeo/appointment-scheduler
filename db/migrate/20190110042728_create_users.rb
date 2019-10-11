class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name, index: true
      t.string :type, index: true
      t.string :time_zone

      t.timestamps
    end
  end
end
