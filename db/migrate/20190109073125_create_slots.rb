class CreateSlots < ActiveRecord::Migration[5.2]
  def change
    create_table :slots do |t|
      t.references :availability, index: true
      t.boolean :available, default: true
      t.string :start

      t.timestamps
    end
  end
end
