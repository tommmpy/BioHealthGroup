class CreateEstudios < ActiveRecord::Migration[8.2]
  def change
    create_table :estudios do |t|
      t.references :user, null: false, foreign_key: true
      t.string :nombre_completo
      t.json :tipo_producto
      t.integer :cantidad_productos
      t.datetime :fecha_estudio
      t.references :branch, null: false, foreign_key: true
      t.integer :medico_id
      t.string :metar_paciente
      t.integer :estado

      t.timestamps
    end
  end
end
