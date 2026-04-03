document.addEventListener('DOMContentLoaded', () => {
    console.log('🚀 BHG Plantales iniciando...');

    // Restaurar usuario desde localStorage
    AppState.restoreUser();

    // Inicializar módulos
    UI.initSidebarEvents();
    AuthModule.init();
    DashboardModule.init();
    PerfilModule.init();
    CalculadoraModule.init();
    HistorialModule.init();

    // Renderizar vista inicial
    if (AppState.user) {
        console.log('✅ Usuario autenticado:', AppState.user.usuario);
        DashboardModule.render();
        PerfilModule.fillForm();
    } else {
        console.log('👤 Modo invitado');
        DashboardModule.renderGuest();
    }

    console.log('✅ App lista');
});