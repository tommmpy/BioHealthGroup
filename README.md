# BioHealthGroup — Sistema de Gestión Clínica Ortopédica

Sistema integral para la Clínica Bio Health Group (Uruguay). Gestión de pacientes,
estudios, turnos, facturación, chat, notificaciones y producción.

Construido con **Ruby on Rails 8** (rama `main`), **Tailwind CSS 4**, **PostgreSQL**
y **Hotwire** (Turbo + Stimulus).

---

## Stack completo

| Capa | Tecnología |
|---|---|
| Backend | Ruby 3.4.9 + Rails 8 (rama `main` de GitHub) |
| Base de datos | PostgreSQL 14+ |
| Frontend | Tailwind CSS 4 + Alpine.js (CDN) + Hotwire (Turbo, Stimulus) |
| Asset pipeline | Propshaft (sin Sprockets) |
| JS bundling | Import Maps (sin Webpack, sin Vite) |
| Caché | Solid Cache (base de datos) |
| Colas | Solid Queue |
| WebSockets | Action Cable + Solid Cable |
| Servidor web | Puma |
| Autenticación | `has_secure_password` con cookies firmadas |
| Tests | Minitest + Capybara + Selenium |

### Gemas destacadas

| Gema | Propósito |
|---|---|
| `pagy` | Paginación |
| `ransack` | Búsqueda y filtros en admin |
| `chartkick` + `groupdate` | Gráficos diarios en dashboard |
| `audited` | Auditoría de cambios en User, Estudio, Branch |
| `prawn` | Generación de PDFs (informes) |
| `premailer-rails` | CSS inline en emails |
| `name_of_person` | Nombre completo (`user.name`) |
| `active_storage_validations` | Validación de imágenes |
| `lograge` | Logs JSON estructurados en producción |
| `rack-cors` | CORS para API REST |
| `letter_opener` | Preview de emails en desarrollo |
| `rack-mini-profiler` | Panel de performance (dev) |
| `view_component` | Componentes reutilizables |

---

## Requisitos

```bash
ruby -v       # 3.4.9
psql --version # 14+
bundler -v     # >= 2.5
node -v        # >= 18 (para Tailwind CLI)
```

---

## Setup local

```bash
# 1. Clonar
git clone https://github.com/tommmpy/BioHealthGroup.git
cd BioHealthGroup

# 2. Variables de entorno
cp .env.example .env
# Editá .env con tus valores

# 3. Instalar dependencias
bundle install

# 4. Preparar base de datos
bin/rails db:create db:migrate db:seed

# 5. Iniciar servidor + watcher de Tailwind
bin/dev
```

Abrí en `http://localhost:3000`.

> **Solución de problemas:** Si `bundle install` da error con gems nativas,
> asegurate de tener `libpq-dev`, `build-essential` y `libvips` instalados.

### Seed data

`rails db:seed` crea:

- **12 sucursales** con direcciones y teléfonos reales de `bhg.uy`
- **Staff** (administradores, médicos, recepcionistas, operarios)
- **Pacientes** de prueba con estudios asociados
- **Empresas** con contacto_root
- **Menores** con contacto_root

Usuarios de prueba creados por seed:

| Email | Contraseña | Rol |
|---|---|---|
| `admin@bhg.uy` | `Test1234` | Administrador |
| `medico@bhg.uy` | `Test1234` | Médico |
| `recepcion@bhg.uy` | `Test1234` | Recepcionista |
| `paciente@bhg.uy` | `Test1234` | Paciente |

---

## Variables de entorno

| Variable | Default | Descripción |
|---|---|---|
| `DATABASE_URL` | — | Conexión a PostgreSQL |
| `APPLICATION_HOST` | `localhost:3000` | Host para emails y hosts permitidos |
| `APPLICATION_URL` | `http://192.168.1.4:3000` | URL base para links en emails |
| `MAILER_FROM` | `noreply@biohealthgroup.uy` | Remitente de emails |
| `CONTACT_EMAIL` | `alveztomas2004@gmail.com` | Destino del formulario de contacto |
| `SMTP_USERNAME` | — | Usuario SMTP |
| `SMTP_PASSWORD` | — | Contraseña SMTP |
| `SMTP_ADDRESS` | `smtp.gmail.com` | Servidor SMTP |
| `SMTP_PORT` | `587` | Puerto SMTP |
| `SMTP_AUTHENTICATION` | `plain` | Método de autenticación SMTP |
| `CORS_ORIGINS` | `http://localhost:3000` | Orígenes permitidos para API |
| `FORCE_SSL` | `true` | Forzar HTTPS (poner `false` en dev local) |
| `ACTIVE_STORAGE_SERVICE` | `local` | Backend de Active Storage |

> ⚠️ En desarrollo local sin HTTPS, poné `FORCE_SSL=false` en tu `.env`.

---

## Comandos útiles

```bash
bin/dev                  # Servidor + Tailwind watcher (desarrollo)
rails server -b 0.0.0.0 # Servidor en IP local (para tests desde otros dispositivos)
rails test               # Ejecutar tests (213 tests, 0 failures esperados)
rails test test/models   # Tests de modelos
rails test test/controllers # Tests de controladores
bundle exec rubocop      # Linter (0 offenses esperados)
rails db:migrate         # Migraciones pendientes
rails db:seed:replant    # Recrear DB + sembrar de nuevo
rails console            # Consola interactiva
rails routes             # Listar rutas
rails credentials:edit   # Editar credenciales cifradas
rails db:reset           # Reset completo de la DB
bundle exec brakeman     # Análisis de seguridad
bundle exec bundler-audit # Auditoría de gems
```

---

## Arquitectura

### Modelos principales

```
User (rol: paciente/recepcionista/medico/operario/administrador/disenador)
├── Branch (sucursal) — pertenece a una sucursal
├── Estudio (estudio ortopédico)
├── Appointment (turno)
├── Invoice (factura)
├── Chat::Room (sala de chat)
├── Notification
└── NotificationPreference

Branch
├── Users
├── Products
└── Appointments

Estudio
├── User (paciente)
├── Branch
├── Medico (User, opcional)
├── ProductionOrder
├── Invoice
└── Files (Active Storage)

Appointment
├── User (paciente)
├── Branch
├── Medico (User)
└── Estudio (opcional)

Chat::Room
├── Chat::Participant (users)
└── Chat::Message
```

### Convenciones de base de datos

- `user_type`: `persona(0)` | `empresa(1)` — columna integer
- `role`: `paciente(0)` | `recepcionista(1)` | `medico(2)` | `operario(3)` | `administrador(4)` | `disenador(5)` — columna integer
- Timestamps en todas las tablas
- Soft-delete no implementado (destroy físico)
- IDs reutilizables vía `ReusableId` concern (encuentra el ID libre más bajo usando advisory lock de PostgreSQL para seguridad concurrente)

### Patrón de autenticación

- `Authentication` concern en `ApplicationController`
- `has_secure_password` con bcrypt
- Sesiones manejadas con `Session` model (cookies firmadas)
- `before_action :require_authentication` por defecto (en `ApplicationController`)
- Usar `allow_unauthenticated_access` para páginas públicas
- `Current.user` disponible en toda la app

### Roles y permisos

| Rol | Acceso |
|---|---|
| `paciente` | Ver estudios propios, agendar turnos, chat |
| `recepcionista` | Admin (sucursal): gestionar pacientes, turnos, estudios |
| `medico` | Admin: ver estudios, informes, producción |
| `operario` | Admin: órdenes de producción, productos |
| `administrador` | Admin completo: usuarios, sucursales, configuración |
| `disenador` | Admin: contenido del sitio (hero slides, testimonios, etc.) |

Los helpers `is_administrador?`, `is_medico?`, `is_recepcionista?`, `is_operario?`,
`is_disenador?`, `is_paciente?` están disponibles en controladores y vistas vía `Roleable`.

---

## Funcionalidades

### 1. Autenticación y registro
- Registro de pacientes (persona física) con validación de cédula
- Login con email y contraseña
- Recuperación de contraseña (token con expiración de 15 minutos)
- Sesión activa con tracking de actividad
- Rate limiting: máximo 5 registros por hora por IP

### 2. Dashboard administrativo
- Acceso `/admin` (restringido a staff)
- Gráficos de usuarios registrados por día (Chartkick)
- Gráficos de estudios por estado y por día
- Órdenes de producción pendientes
- Productos con stock bajo
- Actividad reciente de usuarios

### 3. Gestión de estudios
- CRUD completo con asignación a paciente y sucursal
- Estados: pendiente → en_progreso → finalizado
- Productos ortopédicos (plantares de uso diario/deportivo/niño/adicional)
- Carga de archivos (Active Storage)
- Informes PDF (Prawn)
- Búsqueda y paginación (Ransack + Pagy)
- Finalización requiere `metar_paciente` obligatorio

### 4. Turnos (Appointments)
- Agenda por sucursal con médico asignado
- Solapamiento validado (no se pueden crear turnos que se superpongan para el mismo médico)
- Vista de disponibilidad

### 5. Facturación
- Facturas asociadas a estudios
- Cálculo automático de subtotal, impuestos y total
- Estados de pago
- Múltiples pagos por factura

### 6. Chat en tiempo real
- Salas de chat (soporte y consultas)
- Participantes por sala
- Mensajes en tiempo real vía Action Cable
- Asignación a staff

### 7. Notificaciones
- Notificaciones in-app y por email
- Preferencias configurables por usuario
- Mailer para notificaciones

### 8. Órdenes de producción
- Asociadas a estudios
- Estados y seguimiento
- Asignación a operarios

### 9. Productos
- Gestión de stock por sucursal
- Alertas de stock bajo (umbral: ≤ 5 unidades)

### 10. Sucursales
- 12 sucursales con direcciones y teléfonos reales
- Mapa: enlaces "Ver en Google Maps" con geolocalización (`?q=`)
- Sucursales registradas en Google Maps (Casa Central, Carrasco) muestran nombre + dirección;
  las no registradas muestran solo dirección

### 11. Contenido del sitio (CMS)
- Hero slides con CTA
- Testimonios
- Process steps (cómo funciona)
- Ordenable y activable/desactivable

### 12. API REST JSON
- Endpoints bajo `/api/*`
- Autenticación por cookie de sesión firmada (sin tokens, sin API keys)
- CORS configurable vía `CORS_ORIGINS`

### 13. Formulario de contacto
- Envío a `CONTACT_EMAIL`
- Si el usuario está registrado, link a sala de chat en el email
- Diseño responsivo en HTML email con logo de BHG

### 14. Auditoría
- `audited` registra cambios en `User`, `Estudio`, `Branch`
- Almacenado en tabla `audits` con: quién, qué cambió, cuándo, IP

### 15. Notificaciones push
- Service Worker de PWA configurado (public/service-worker.js)
- Botón de instalación de app en escritorio/móvil

---

## Modelo de datos: detalle

### User (`users`)
| Columna | Tipo | Notas |
|---|---|---|
| `email_address` | string | Único, normalizado a minúsculas |
| `password_digest` | string | bcrypt |
| `first_name`, `last_name` | string | Mín. 2, máx. 50 caracteres |
| `ci` | string | Cédula de identidad |
| `phone_number` | string | Formato: `099123456` o `+59899123456` |
| `branch_id` | bigint | FK a sucursal |
| `address` | string | Máx. 100 caracteres |
| `role` | integer | 0-5 (paciente a diseñador) |
| `user_type` | integer | 0=persona, 1=empresa |
| `contacto_root` | string | Requerido si empresa O menor de 18 |
| `birthday` | date | Para calcular edad |
| `status` | integer | 0=disponible, 1=ausente, 2=no_molestar, 3=desconectado |

### Estudio (`estudios`)
| Columna | Tipo | Notas |
|---|---|---|
| `user_id` | bigint | FK paciente (NOT NULL) |
| `branch_id` | bigint | FK sucursal |
| `medico_id` | bigint | FK médico (opcional) |
| `nombre_completo` | string | Nombre del paciente en el estudio |
| `tipo_producto` | json | Array de productos |
| `cantidad_productos` | integer | Calculado automáticamente |
| `fecha_estudio` | datetime | Fecha del estudio |
| `metar_paciente` | string | Requerido para finalizar |
| `estado` | integer | 0=pendiente, 1=en_progreso, 2=finalizado |

---

## API REST

### Endpoints disponibles

```
GET    /api/v1/estudios         # Listar estudios
GET    /api/v1/estudios/:id     # Ver estudio
POST   /api/v1/estudios         # Crear estudio
PATCH  /api/v1/estudios/:id     # Actualizar estudio
DELETE /api/v1/estudios/:id     # Eliminar estudio
```

### Autenticación

La API usa la misma cookie de sesión que la web (cookie firmada `session_id`).
No se requieren tokens adicionales. Envío automático si el navegador está autenticado.

### Respuestas

```json
// Éxito: 200
{ "id": 1, "nombre_completo": "Juan Pérez", "estado": "pendiente", ... }

// Error: 401
{ "error": "Autenticación requerida" }

// Error: 404
{ "error": "No encontrado" }

// Error: 422
{ "errors": ["nombre_completo no puede estar en blanco"] }
```

---

## Correos electrónicos

| Mailer | Propósito | Template |
|---|---|---|
| `ContactMailer` | Formulario de contacto → admin | HTML + texto |
| `WelcomeMailer` | Bienvenida al registrarse | HTML |
| `NotificationMailer` | Notificaciones del sistema | HTML |

### Configuración SMTP

El sistema soporta cualquier proveedor SMTP (Gmail, Mailgun, SendGrid, etc.)
configurable vía variables de entorno. Ver sección [Variables de entorno](#variables-de-entorno).

En desarrollo, los emails se previewan en el navegador gracias a `letter_opener`
(`http://localhost:3000/letter_opener`).

---

## Tests

```bash
rails test                    # Todos los tests (213, 0 failures)
rails test test/models        # Modelos
rails test test/controllers   # Controladores
rails test test/system        # Tests de sistema (requiere Chrome)
bundle exec rubocop           # Linter (0 offenses)
bundle exec brakeman          # Seguridad
bundle exec bundler-audit     # Auditoría de gems
```

### Fixtures

- `test/fixtures/users.yml` — usuarios de prueba con CIs válidas
- `test/fixtures/branches.yml` — sucursales
- `test/fixtures/estudios.yml` — estudios

> ⚠️ `user_type` y `role` son columnas integer. Usar ERB en fixtures:
> `<%= User::USER_TYPES[:persona] %>`. No usar strings literales.

---

## Seguridad

- Contraseñas: bcrypt con mínimo 8 caracteres, mayúscula + minúscula + número
- Sesiones: cookies firmadas con `Rails.application.config.secret_key_base`
- Rate limiting: 5 registros/hora/IP
- Hosts permitidos: configurados en producción via `APPLICATION_HOST`
- CORS: restrictivo por origen configurable
- SQL injection: prevenido por ActiveRecord parameterized queries
- Audit trail: todos los cambios críticos registrados
- Contenido de emails: CSS inline con Premailer para compatibilidad
- IDs reutilizables: protegidos con advisory lock para evitar race conditions
- Eliminación de usuarios: restringida si tiene estudios, facturas o turnos asociados

---

## Solución de problemas comunes

### `peer authentication failed` en PostgreSQL
Si usás ident/peer auth, configurá `DATABASE_URL` con usuario/password:
```
DATABASE_URL=postgres://tu_usuario:tu_password@localhost:5432/bio_health_group_dev
```
O editá `pg_hba.conf` para cambiar a `md5`.

### Error de gems nativas al compilar
```bash
sudo apt-get install libpq-dev build-essential libvips-dev
```

### Tests fallan por fixtures
Asegurate de que `user_type` y `role` usen ERB con valores enteros:
```yaml
user_type: <%= User::USER_TYPES[:persona] %>
role: <%= User::ROLES[:paciente] %>
```

### Email no se envía en desarrollo
Letter Opener captura los emails en vez de enviarlos.
Revisá `http://localhost:3000/letter_opener` o la consola del servidor.

---

## Licencia

MIT
