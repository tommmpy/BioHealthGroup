class CreateAppointments < ActiveRecord::Migration[8.2]
  def change
    create_table :appointments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :estudio, null: true, foreign_key: true
      t.bigint :medico_id, null: true
      t.references :branch, null: false, foreign_key: true
      t.string :title, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.integer :status, default: 0
      t.text :notes

      t.timestamps
    end

    add_index :appointments, :medico_id
    add_index :appointments, :starts_at
    add_foreign_key :appointments, :users, column: :medico_id
  end
end
