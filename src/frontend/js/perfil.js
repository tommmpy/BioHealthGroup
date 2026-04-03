const PerfilModule = (() => {
    const form = {
        ciUsuario: document.getElementById('ciPerfil'),
        nombre: document.getElementById('nombrePerfil'),
        usuario: document.getElementById('usuarioPerfil'),
        email: document.getElementById('emailPerfil'),
        fecha: document.getElementById('fechaPerfil'),
        rol: document.getElementById('rolPerfil'),
        sucursal: document.getElementById('sucursalPerfil'),
        password: document.getElementById('passwordPerfil'),
        guardar: document.getElementById('guardarPerfilBtn'),
        cancelar: document.getElementById('cancelarPerfilBtn'),
    };

    const fillForm = () => {
        if (!AppState.user) return;
        form.ciUsuario.value = AppState.user.usuario || '';
        form.nombre.value = AppState.user.nombre || '';
        form.usuario.value = AppState.user.usuario || '';
        form.email.value = AppState.user.email || '';
        form.fecha.value = AppState.user.fecha_nacimiento || '';
        form.rol.value = AppState.user.rol || '';
        form.sucursal.value = AppState.user.sucursal || '';
        form.password.value = '';
    };

    const handleSave = async () => {
        if (!AppState.user) return;

        const payload = {
            nombre: form.nombre.value.trim(),
            fecha_nacimiento: form.fecha.value || null,
            sucursal: form.sucursal.value.trim() || null
        };

        if (form.password.value.trim()) {
            payload.password = form.password.value.trim();
        }

        try {
            const res = await API.updateUser(AppState.user.usuario, payload);
            
            if (!res.ok) {
                UI.showToast('❌ ' + (res.error || 'No se pudo actualizar'));
                return;
            }

            AppState.setUser(res.user);
            UI.setUserBadge(AppState.user.nombre);
            fillForm();
            HistorialModule.add('💾 Perfil actualizado');
            UI.showToast('✅ Perfil guardado');

        } catch (err) {
            UI.showToast('❌ Error: ' + err.message);
        }
    };

    const init = () => {
        form.guardar?.addEventListener('click', (e) => {
            e.preventDefault();
            handleSave();
        });

        form.cancelar?.addEventListener('click', (e) => {
            e.preventDefault();
            fillForm();
        });

        DOM.menuPerfil?.addEventListener('click', () => {
            UI.showPage(DOM.perfilSection);
            UI.setActiveMenu(DOM.menuPerfil);
            fillForm();
            UI.closeSidebar();
        });
    };

    return { init, fillForm };
})();