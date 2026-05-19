# BioHealthGroup — Clínica Ortopédica

Sistema de gestión integral para la Clínica Ortopédica Bio Health Group.
Construido con **Ruby on Rails 8**, **Tailwind CSS 4**, **PostgreSQL** y **Hotwire**.

## Stack

- **Ruby 3.4.9** + **Rails 8** (main branch)
- **PostgreSQL** — base de datos principal
- **Tailwind CSS 4** + **Alpine.js** (CDN) — frontend
- **Propshaft** — asset pipeline (sin Sprockets)
- **Solid Cache / Solid Queue / Solid Cable** — adaptadores数据库
- **Puma** — servidor web

## Requisitos

- Ruby 3.4.9
- PostgreSQL 14+
- Bundler
- Node.js (para Tailwind CSS CLI)

## Setup local

```bash
git clone https://github.com/tommmpy/BioHealthGroup.git
cd BioHealthGroup
bundle install
bin/rails db:create db:migrate db:seed
bin/dev
```

Abre en `http://localhost:3000`.

### Variables de entorno

Copiá `.env.example` a `.env` y completá según corresponda.

## Comandos útiles

| Comando | Descripción |
|---|---|
| `bin/dev` | Servidor + Tailwind watcher |
| `rails test` | Tests (44 tests, 0 failures) |
| `rails db:seed:replant` | Resembrar DB |
| `bundle exec rubocop` | Linter (0 offenses) |

## Deploy

No configurado. Para deploy manual:

```bash
RAILS_ENV=production bin/rails db:prepare db:seed
RAILS_ENV=production bin/rails assets:precompile
RAILS_ENV=production bin/rails server
```

## Roles de usuario

`Roleable` concern: `paciente(0)`, `recepcionista(1)`, `medico(2)`, `operario(3)`,
`administrador(4)`, `disenador(5)`.

## Funcionalidades principales

- Autenticación con `has_secure_password` (cookies)
- Dashboard admin con gráficos (Chartkick + Groupdate)
- Chat en tiempo real (Action Cable)
- Notificaciones con preferencias
- Estudios, turnos, facturación, órdenes de producción
- Carga de archivos (Active Storage)
- API REST JSON
- Auditoría (Audited gem)
- Paginación (Pagy), búsqueda (Ransack)
- Emails con preview (Letter Opener en dev)
- Logs estructurados (Lograge)

## Licencia

MIT
