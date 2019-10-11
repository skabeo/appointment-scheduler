class CreateAppointments < ActiveRecord::Migration[5.2]
  def change
    create_table :appointments do |t|
      t.integer :student_id, index: true
      t.integer :coach_id, index: true
      t.references :slot, index: true

      t.timestamps
    end
  end
end
