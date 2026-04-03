const AuthModule = (() => {
    const loginForm = {
        usuario: document.getElementById('usuarioInput'),
        password: document.getElementById('passwordInput'),
        error: document.getElementById('loginError'),
        btn: document.getElementById('btnLogin'),
        irRegistro: document.getElementById('btnIrRegistro'),
    };

    const registroForm = {
        nombre: document.getElementById('nombreRegistro'),
        usuario: document.getElementById('usuarioRegistro'),
        password: document.getElementById('passwordRegistro'),
        confirmPassword: document.getElementById('confirmPasswordRegistro'),
        fecha: document.getElementById('fechaRegistro'),
        sucursal: document.getElementById('sucursalRegistro'),
        error: document.getElementById('registerError'),
        btn: document.getElementById('btnRegister'),
        irLogin: document.getElementById('btnIrLogin'),
    };

    const btnMostrarLogin = document.getElementById('btnMostrarLogin');
    const btnMostrarRegistro = document.getElementById('btnMostrarRegistro');

    const handleLogin = async () => {
        loginForm.error.textContent = '';
        const usuario = loginForm.usuario.value.trim();
        const password = loginForm.password.value.trim();

        if (!usuario || !password) {
            loginForm.error.textContent = '⚠️ Completa usuario y contraseña';
            return;
        }

        try {
            const res = await API.login(usuario, password);

            if (!res.ok) {
                loginForm.error.textContent = '❌ ' + (res.error || 'Credenciales inválidas');
                return;
            }

            loginForm.usuario.value = '';
            loginForm.password.value = '';
            loginForm.error.textContent = '';

            AppState.setUser(res.user);
            HistorialModule.add(`✅ Sesión iniciada como ${res.user.usuario}`);
            DashboardModule.render();
            UI.showToast('✅ ¡Bienvenido ' + res.user.nombre + '!');

        } catch (err) {
            loginForm.error.textContent = '❌ Error de conexión: ' + err.message;
        }
    };

    const handleRegister = async () => {
        registroForm.error.textContent = '';
        const nombre = registroForm.nombre.value.trim();
        const usuario = registroForm.usuario.value.trim();
        const password = registroForm.password.value.trim();
        const confirmPassword = registroForm.confirmPassword.value.trim();

        if (!nombre || !usuario || !password || !confirmPassword) {
            registroForm.error.textContent = '⚠️ Completa todos los campos requeridos';
            return;
        }

        if (password !== confirmPassword) {
            registroForm.error.textContent = '⚠️ Las contraseñas no coinciden';
            return;
        }

        if (password.length < 4) {
            registroForm.error.textContent = '⚠️ La contraseña debe tener al menos 4 caracteres';
            return;
        }

        const fecha_nacimiento = registroForm.fecha.value || null;
        const sucursal = registroForm.sucursal.value.trim() || null;

        try {
            const res = await API.register(nombre, usuario, password, fecha_nacimiento, sucursal);

            if (!res.ok) {
                registroForm.error.textContent = '❌ ' + (res.error || 'Error de registro');
                return;
            }

            registroForm.nombre.value = '';
            registroForm.usuario.value = '';
            registroForm.password.value = '';
            registroForm.confirmPassword.value = '';
            registroForm.fecha.value = '';
            registroForm.sucursal.value = '';
            registroForm.error.textContent = '';

            UI.showToast('✅ Registro exitoso. Inicia sesión.');
            setTimeout(() => btnMostrarLogin.click(), 1000);

        } catch (err) {
            registroForm.error.textContent = '❌ Error: ' + err.message;
        }
    };

    const handleLogout = () => {
        AppState.clearUser();
        HistorialModule.clear();
        DashboardModule.renderGuest();
        UI.showToast('👋 Sesión cerrada');
    };

    const init = () => {
        loginForm.btn.addEventListener('click', handleLogin);
        registroForm.btn.addEventListener('click', handleRegister);
        DOM.btnCerrarSesion?.addEventListener('click', handleLogout);

        btnMostrarLogin?.addEventListener('click', (e) => {
            e.preventDefault();
            UI.showPage(DOM.loginSection);
            UI.setActiveMenu(null);
            UI.closeSidebar();
        });

        btnMostrarRegistro?.addEventListener('click', (e) => {
            e.preventDefault();
            UI.showPage(DOM.registroSection);
            UI.setActiveMenu(null);
            UI.closeSidebar();
        });

        loginForm.irRegistro?.addEventListener('click', (e) => {
            e.preventDefault();
            UI.showPage(DOM.registroSection);
            loginForm.error.textContent = '';
            UI.setActiveMenu(null);
        });

        registroForm.irLogin?.addEventListener('click', (e) => {
            e.preventDefault();
            UI.showPage(DOM.loginSection);
            registroForm.error.textContent = '';
            UI.setActiveMenu(null);
        });

        // Enter en inputs
        loginForm.password.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') handleLogin();
        });

        registroForm.confirmPassword.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') handleRegister();
        });
    };

    return { init };
})();