# BioHealthGroup — Project Context for AI Agents

## Stack
- Rails 8 (main branch) + Propshaft (no Sprockets)
- Tailwind CSS v4 + Alpine.js (CDN)
- PostgreSQL, Solid Cache, Solid Queue
- Puma for local server

## Quick Commands
- `bin/dev` — server + Tailwind watcher
- `rails test` — 44 tests, 0 failures expected
- `rails db:seed` — seeds with staff, pacientes, empresas, menores
- `bundle exec rubocop` — 0 offenses expected
- `rails db:seed:replant` if needed

## Architecture Notes
- CSS: `app/assets/stylesheets/application.css` (1.3KB, only custom). Everything else via Tailwind classes.
- Assets: Propshaft (no importmap for CSS). Images in `app/assets/images/`.
- Auth: `Authentication` concern via cookie sessions (`has_secure_password`). `before_action :require_authentication` in ApplicationController by default; use `allow_unauthenticated_access` for public pages.
- Roles (Roleable concern): paciente(0), recepcionista(1), medico(2), operario(3), administrador(4), disenador(5)
- User types: persona(0), empresa(1) — stored as integer. `empresa?`/`persona?` methods available.
- `contacto_root` validation: required if empresa, or if persona AND under 18.
- Routing: `resource :contact, only: [:create]` maps to `ContactsController` (plural).

## Mailer Setup
- SMTP via env vars: `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_AUTHENTICATION`
- `APPLICATION_HOST` for email links host
- `MAILER_FROM` for sender address (default: noreply@biohealthgroup.uy)
- `CONTACT_EMAIL` for contact form destination (default: alveztomas2004@gmail.com)
- `APPLICATION_URL` for chat room URLs in contact mailer

## Fixture Gotchas
- `user_type` and `role` are integer columns in DB. Use ERB in fixtures: `<%= User::USER_TYPES[:persona] %>`
- Bypassing the model setter means raw string values like `persona` become `nil`.

## Key Files
- `config/environments/production.rb` — SMTP config via env
- `app/models/concerns/roleable.rb` — roles, user_types, empresa?/persona?
- `app/controllers/concerns/authentication.rb` — session management
- `app/assets/stylesheets/application.css` — only custom CSS
- `test/fixtures/users.yml` — test users with valid CIs

## Added Gems
- **pagy** (~> 9.0) — pagination on admin users, estudios, and notifications index
- **name_of_person** — proper person name display (`user.name` instead of concatenation)
- **letter_opener** — preview emails in browser during development
- **rack-mini-profiler** — performance panel (bottom-left, Alt+P, dev only)
- **ransack** — search/filter on admin index pages (users, estudios)
- **chartkick** + **groupdate** — charts on admin dashboard (users/day, estudios/day, estudios by status)
- **premailer-rails** — auto-inline CSS in HTML emails for email client compatibility
- **audited** — audit trail on User, Estudio, Branch (stored in `audits` table)
- **active_storage_validations** — validate image content_type and size on HeroSlide, ProcessStep, Testimonial
- **lograge** — structured JSON logging in production (one line per request)

## Known Issues
- **bullet** gem not compatible with Rails 8.2.0.alpha — re-add when upstream fixes it
- **annotate** gem not compatible with Ruby 3.4 (uses deprecated `File.exists?`)
- Rails 8 (main branch) means some gems may not yet be compatible — test after adding
