json.(@estudio, :id, :nombre_completo, :tipo_producto, :fecha_estudio, :estado, :cantidad_productos, :metar_paciente, :created_at, :updated_at)
json.paciente do
  json.(@estudio.user, :id, :first_name, :last_name, :ci, :email_address, :phone_number) if @estudio.user
end
json.medico do
  json.(@estudio.medico, :id, :first_name, :last_name) if @estudio.medico
end
