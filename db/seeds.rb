# frozen_string_literal: true

require "faker"
Faker::Config.locale = "es"

# ── Helpers ────────────────────────────────────────────────────────────────

def generate_uruguayan_ci
  weights = [ 2, 9, 8, 7, 6, 3, 4 ]
  digits = Array.new(7) { rand(0..9) }
  sum = digits.each_with_index.sum { |d, i| d * weights[i] }
  check_digit = (10 - (sum % 10)) % 10
  (digits << check_digit).join
end

def generate_phone
  "09#{rand(10_000_000).to_s.rjust(7, "0")}"
end

def random_branch
  Branch.order("RANDOM()").first
end

def random_status
  User::STATUSES.keys.sample
end

# ── Cleanup ────────────────────────────────────────────────────────────────

puts "--- Limpiando base de datos ---"

ActiveRecord::Base.connection.execute(
  "TRUNCATE TABLE #{(
    %w[
      messages chat_room_participants chat_rooms
      notifications sessions estudios users
      hero_slides process_steps testimonials audits
    ].map { |t| "\"#{t}\"" } + [ "active_storage_attachments", "active_storage_blobs" ]
  ).join(", ")} RESTART IDENTITY CASCADE"
)

# ── Branches ───────────────────────────────────────────────────────────────

puts "--- Cargando las 12 sedes ---"

branches_data = [
  { name: "BHG - Casa Central",  address: "Dr. José María Montero 2613, Punta Carretas",          phone: "2710 1234" },
  { name: "BHG - Carrasco",      address: "Cartagena 1642, Carrasco",                              phone: "2600 5678" },
  { name: "BHG - Solymar",       address: "Av. Real de Azúa, Solymar, Canelones",                 phone: "2696 4321" },
  { name: "BHG - Pando",         address: "Av. Artigas (Dr. Correch 1119), Pando",                 phone: "2292 2222" },
  { name: "BHG - Las Piedras",   address: "Aparicio Saravia 587, Las Piedras",                     phone: "2364 3333" },
  { name: "BHG - Maldonado",     address: "Av. Roosevelt y Henry Dunant, Maldonado",               phone: "4224 8888" },
  { name: "BHG - Mercedes",      address: "Cristóbal Colón 238, Mercedes",                         phone: "4532 1111" },
  { name: "BHG - Paysandú",      address: "Montecaseros 721 esq. Colón, Paysandú",                 phone: "4722 9999" },
  { name: "BHG - Minas",         address: "Juan Farina 401, Minas",                                phone: "4442 4444" },
  { name: "BHG - Rosario",       address: "Cerrito 237, Rosario",                                  phone: "4552 5555" },
  { name: "BHG - Salto",         address: "Treinta y Tres 42, Salto",                              phone: "4733 1111" },
  { name: "BHG - Melo",          address: "Mata 525, Melo",                                        phone: "4642 6666" }
]

branches = branches_data.map do |data|
  Branch.find_or_create_by!(name: data[:name]) do |b|
    b.assign_attributes(address: data[:address], phone: data[:phone], enabled: true)
  end
end

central = branches.first

# ── Users ──────────────────────────────────────────────────────────────────

puts "--- Creando staff ---"

admin = User.create!(
  email_address: "admin@bhg.uy",
  password: "AdminPassword2026",
  first_name: "Admin",
  last_name: "General",
  phone_number: generate_phone,
  address: "Sede Central",
  ci: generate_uruguayan_ci,
  branch: central,
  role: :administrador,
  user_type: :persona,
  birthday: "1980-01-01",
  status: :disponible
)

medico = User.create!(
  email_address: "medico@bhg.uy",
  password: "MedicoPassword2026",
  first_name: "Andrés",
  last_name: "Sosa",
  phone_number: generate_phone,
  address: "Consultorio Central",
  ci: generate_uruguayan_ci,
  branch: central,
  role: :medico,
  user_type: :persona,
  birthday: "1985-05-20",
  status: :disponible
)

# Staff distribuido en varias sedes
staff_data = [
  { email: "recepcion@bhg.uy",       pass: "RecepPassword2026",  first: "Lucía",   last: "Fernández",   role: :recepcionista, branch: central,    birthday: "1992-10-10" },
  { email: "operario@bhg.uy",        pass: "OperarioPass2026",   first: "Carlos",  last: "Rodríguez",   role: :operario,      branch: branches[1], birthday: "1990-08-12" },
  { email: "disenador@bhg.uy",       pass: "DisenadorPass2026",  first: "Sofía",   last: "Martínez",    role: :disenador,     branch: branches[2], birthday: "1993-11-25" },
  { email: "medico2@bhg.uy",         pass: "MedicoPass2026",     first: "María",   last: "López",       role: :medico,        branch: branches[3], birthday: "1982-03-08" },
  { email: "recepcion2@bhg.uy",      pass: "RecepPass2026",      first: "Pedro",   last: "García",      role: :recepcionista, branch: branches[4], birthday: "1995-07-22" }
]

staff = staff_data.map do |s|
  User.create!(
    email_address: s[:email],
    password: s[:pass],
    first_name: s[:first],
    last_name: s[:last],
    phone_number: generate_phone,
    address: Faker::Address.street_address,
    ci: generate_uruguayan_ci,
    branch: s[:branch],
    role: s[:role],
    user_type: :persona,
    birthday: s[:birthday],
    status: random_status
  )
end

puts "--- Creando empresas ---"

empresas_data = [
  { name: "Club Atlético Peñarol",       contacto: "Club Atlético Peñarol - 2487 1000" },
  { name: "Selección Uruguaya de Rugby", contacto: "Unión de Rugby del Uruguay - 2710 5678" },
  { name: "Club Nacional de Football",   contacto: "Club Nacional de Football - 2487 2000" }
]

empresas = empresas_data.map do |e|
  User.create!(
    email_address: "#{e[:name].parameterize(separator: ".")}@bhg.uy",
    password: "EmpresaPass2026",
    first_name: e[:name].split.first,
    last_name: e[:name].split[1..].join(" "),
    phone_number: generate_phone,
    address: Faker::Address.street_address,
    ci: generate_uruguayan_ci,
    branch: random_branch,
    role: :paciente,
    user_type: :empresa,
    contacto_root: e[:contacto],
    birthday: "2000-01-01",
    status: random_status
  )
end

puts "--- Creando pacientes menores de edad ---"

menores = 5.times.map do
  User.create!(
    email_address: "menor.#{rand(100_000)}@example.com",
    password: "MenorPass2026",
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    phone_number: generate_phone,
    address: Faker::Address.street_address,
    ci: generate_uruguayan_ci,
    branch: random_branch,
    role: :paciente,
    user_type: :persona,
    birthday: Faker::Date.birthday(min_age: 5, max_age: 17),
    contacto_root: "Tutor: #{generate_phone}",
    status: random_status
  )
end

puts "--- Creando pacientes mayores de edad ---"

adultos = 30.times.map do |i|
  User.create!(
    email_address: "paciente.#{i + 1}@example.com",
    password: "PacientePass2026",
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    phone_number: generate_phone,
    address: Faker::Address.street_address,
    ci: generate_uruguayan_ci,
    branch: random_branch,
    role: :paciente,
    user_type: :persona,
    birthday: Faker::Date.birthday(min_age: 18, max_age: 80),
    contacto_root: nil,
    status: random_status
  )
end

pacientes = menores + adultos

# ── Estudios ───────────────────────────────────────────────────────────────

puts "--- Creando estudios ---"

productos = Estudio::PRODUCTOS_PERMITIDOS
estados = %i[pendiente en_progreso finalizado]

100.times do
  paciente = pacientes.sample
  tipo = productos.sample(rand(1..3))
  created_at = rand(-90..0).days.ago
  fecha_estudio = created_at + rand(1..14).days
  estado = estados.sample

  estudio = Estudio.new(
    user: paciente,
    nombre_completo: "#{paciente.first_name} #{paciente.last_name}",
    tipo_producto: tipo,
    cantidad_productos: tipo.size,
    fecha_estudio: fecha_estudio,
    branch: random_branch,
    estado: estado,
    medico_id: (estado == :en_progreso || estado == :finalizado ? medico.id : nil)
  )

  if estado == :finalizado
    estudio.metar_paciente = "11/#{rand(10..99)}/#{rand(10..99)}/#{rand(10..99)}"
  end

  estudio.save!
end

# ── Chat ───────────────────────────────────────────────────────────────────

puts "--- Creando conversaciones de chat ---"

staff_users = [ admin, medico ] + staff
all_staff = [ admin, medico ] + staff
patient_pool = pacientes.sample(15)

patient_pool.each do |paciente|
  supporter = all_staff.select { |u| !u.paciente? }.sample
  next if supporter.nil?

  existing = Chat::Conversation.joins(:chat_room_participants)
    .where(chat_rooms: { kind: "support" })
    .where(chat_room_participants: { user_id: supporter.id })
    .merge(Chat::Conversation.joins(:chat_room_participants)
      .where(chat_room_participants: { user_id: paciente.id }))

  next if existing.exists?

  conversation = Chat::Conversation.create!(kind: "support")
  conversation.chat_room_participants.create!(user: supporter)
  conversation.chat_room_participants.create!(user: paciente)

  rand(1..4).times do
    sender = [ supporter, paciente ].sample
    conversation.messages.create!(
      user: sender,
      content: Faker::Lorem.sentence(word_count: rand(3..12)),
      created_at: rand(-7..0).days.ago
    )
  end
end

# ── Notifications ──────────────────────────────────────────────────────────

puts "--- Creando notificaciones ---"

pacientes.sample(20).each do |paciente|
  estudio = paciente.estudios.first
  next unless estudio

  Notification.create!(
    user: paciente,
    notifiable: estudio,
    kind: "recordatorio",
    title: "Recordatorio de estudio",
    body: "Tiene un estudio pendiente en #{estudio.branch.name}. Por favor agende su visita.",
    read: [ true, false ].sample,
    created_at: rand(-14..0).days.ago
  )
end

# ── Home page content ──────────────────────────────────────────────────────

puts "--- Creando contenido de la página de inicio ---"

HeroSlide.find_or_create_by!(title: "Estudio y Valoración Biomecánica") do |s|
  s.subtitle = "A través de nuestro software profesional FreeStep y la línea de plataformas FreeMed de Sensor Medica Italia, logramos realizar un completo estudio biomecánico del movimiento."
  s.cta_text = "Agendar Estudio"
  s.cta_link = "/dashboard"
  s.sort_order = 0
  s.active = true
end

HeroSlide.find_or_create_by!(title: "Cinta de correr sensorizada") do |s|
  s.subtitle = "Contamos con tecnología de punta en nuestro Estudio Biomecánico. Los deportistas obtendrán información más específica sobre su marcha y carrera."
  s.cta_text = "Agendar Estudio"
  s.cta_link = "/dashboard"
  s.sort_order = 1
  s.active = true
end

HeroSlide.find_or_create_by!(title: "Software sofisticado de diseño") do |s|
  s.subtitle = "El software integrado más potente jamás creado, validado por decenas de publicaciones científicas internacionales."
  s.cta_text = "Conocer más"
  s.cta_link = "/dashboard"
  s.sort_order = 2
  s.active = true
end

HeroSlide.find_or_create_by!(title: "Representantes Sensor Medica") do |s|
  s.subtitle = "Somos representantes exclusivos de Sensor Medica Italia. Contamos con toda la tecnología italiana en equipos y software, venta de productos y servicio postventa."
  s.cta_text = "Solicitar Asesoramiento"
  s.cta_link = "/dashboard"
  s.sort_order = 3
  s.active = true
end

ProcessStep.find_or_create_by!(step_number: 1) do |s|
  s.title = "Estudio y Valoración Biomecánica"
  s.description = "Un técnico realiza un estudio y valoración biomecánica, hace una devolución específica en persona y luego se envía vía mail los resultados completos."
  s.icon = "paso01.webp"
  s.active = true
end

ProcessStep.find_or_create_by!(step_number: 2) do |s|
  s.title = "Diseño Ortósico"
  s.description = "A partir de los resultados, se realiza el diseño ortósico a medida en Easy Cad Insole. Cada diseño es 100% personalizado."
  s.icon = "paso02.webp"
  s.active = true
end

ProcessStep.find_or_create_by!(step_number: 3) do |s|
  s.title = "Elaboración del Plantar"
  s.description = "Se selecciona el material Eva de Italia y se ingresa el diseño en una Fresadora CNC que produce automáticamente el plantar personalizado."
  s.icon = "paso03.webp"
  s.active = true
end

ProcessStep.find_or_create_by!(step_number: 4) do |s|
  s.title = "Re-evaluación Biomecánica"
  s.description = "Al año comunicamos al paciente que debe volver a re-evaluarse. Analizamos los plantares para evaluar su estado y porcentaje de uso."
  s.icon = "paso04.webp"
  s.active = true
end

Testimonial.find_or_create_by!(author_name: "Lucia Santucci") do |t|
  t.author_role = "ATLETA"
  t.content = "Luego de una lesión que me dejó sin correr durante varios meses, decidí prestar un poco más de atención al cuerpo, mi pisada y realizarme un estudio biomecánico junto a BHG. Y a raíz de esto, incorporar plantares, lo que fue clave para evitar compensaciones al igual que ciertas cargas extras al correr. Mi experiencia junto a los plantares fue muy positiva, tuve un periodo de adaptación corto y me hacen sentir mucho más confiada."
  t.sort_order = 0
  t.active = true
end

Testimonial.find_or_create_by!(author_name: "Maxi Vázquez") do |t|
  t.author_role = "ATLETA"
  t.content = "En esta etapa de mi carrera como atleta de élite me di cuenta de la necesidad e importancia de tener un equipo; fue ahí que conocí a BHG. Necesitaba conocer más y mejor a mi cuerpo y cómo se comportaba mecánicamente en las diferentes etapas de una carrera. Encontré en sus plantares personalizados un apoyo que hoy es indispensable."
  t.sort_order = 1
  t.active = true
end

Testimonial.find_or_create_by!(author_name: "Debbie Goldfarb") do |t|
  t.author_role = "PACIENTE"
  t.content = "Nací con una patología en los pies y, con el paso de los años, la situación fue empeorando. Solía disfrutar de largas caminatas, pero en los últimos tiempos tuve que abandonarlas: los dolores en los pies y la espalda eran cada vez más intensos. Cuando escuché sobre BHG decidí darme una última oportunidad. ¡Y fue lo mejor que pude haber hecho!"
  t.sort_order = 2
  t.active = true
end

# ── Attach images ──────────────────────────────────────────────────────────

seed_dir = Rails.root.join("app/assets/images/seed")

hero_images = {
  "Estudio y Valoración Biomecánica" => "slider.webp",
  "Cinta de correr sensorizada"      => "hero_cinta.webp",
  "Software sofisticado de diseño"   => "hero_software.jpg",
  "Representantes Sensor Medica"     => "hero_sensor.webp"
}

hero_images.each do |title, file|
  slide = HeroSlide.find_by(title: title)
  path = seed_dir.join(file)
  next unless slide && File.exist?(path) && !slide.image.attached?

  slide.image.attach(io: File.open(path), filename: file, content_type: file.end_with?(".jpg") ? "image/jpeg" : "image/webp")
  puts "  -> Imagen hero \"#{title}\" attachada"
end

ProcessStep.sorted.each do |step|
  path = seed_dir.join(step.icon)
  next unless step.icon.present? && File.exist?(path) && !step.image.attached?

  step.image.attach(io: File.open(path), filename: step.icon, content_type: "image/webp")
  puts "  -> Imagen paso #{step.step_number} attachada"
end

{
  "Lucia Santucci"  => "testimonial_lucia.webp",
  "Maxi Vázquez"    => "testimonial_maxi.webp",
  "Debbie Goldfarb" => "testimonial_debbie.webp"
}.each do |name, file|
  t = Testimonial.find_by(author_name: name)
  path = seed_dir.join(file)
  next unless t && File.exist?(path) && !t.avatar.attached?

  t.avatar.attach(io: File.open(path), filename: file, content_type: "image/webp")
  puts "  -> Avatar #{name} attachado"
end

puts "--- Seeds completadas con éxito ---"
puts "  Sedes: #{Branch.count}"
puts "  Usuarios: #{User.count} (#{User.where(role: User::ROLES[:paciente]).count} pacientes)"
puts "  Estudios: #{Estudio.count}"
puts "  Conversaciones: #{Chat::Conversation.count}"
puts "  Mensajes: #{Chat::Message.count}"
puts "  Notificaciones: #{Notification.count}"
