class CreateAvailabilities < ActiveRecord::Migration[5.2]
  def change
    create_table :availabilities do |t|
      t.references :user, index: true
      t.integer :day_of_week
      t.string :start
      t.string :end

      t.timestamps
    end
  end
end
