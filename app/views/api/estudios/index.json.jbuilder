json.array! @estudios do |estudio|
  json.(estudio, :id, :nombre_completo, :tipo_producto, :fecha_estudio, :estado, :cantidad_productos, :created_at)
  json.paciente do
    json.(estudio.user, :id, :first_name, :last_name, :ci) if estudio.user
  end
  json.medico do
    json.(estudio.medico, :id, :first_name, :last_name) if estudio.medico
  end
end
