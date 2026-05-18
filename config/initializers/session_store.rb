# Al no poner 'expire_after', la cookie es de "Sesión" por defecto.
Rails.application.config.session_store :cookie_store, key: "_bhg_session"
