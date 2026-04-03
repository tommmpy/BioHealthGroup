const DashboardModule = (() => {
    const deudaDisplay = document.getElementById('deudaActualDisplay');
    const interesDisplay = document.getElementById('interesActualDisplay');
    const totalDisplay = document.getElementById('totalDisplay');
    const homeTitle = document.getElementById('homeTitle');
    const homeMessage = document.getElementById('homeMessage');
    const guestActions = document.getElementById('guestActions');
    const authWidgets = document.getElementById('authWidgets');
    const authActions = document.getElementById('authActions');

    const btnAplicarInteres = document.getElementById('btnAplicarInteres');
    const btnReiniciar = document.getElementById('btnReiniciar');

    const render = () => {
        // Usuario autenticado
        DOM.menuPerfil.style.display = 'block';
        DOM.menuCalculadora.style.display = 'block';
        DOM.menuHistorico.style.display = 'block';
        DOM.btnCerrarSesion.style.display = 'block';

        btnAplicarInteres.disabled = false;
        btnReiniciar.disabled = false;

        homeTitle.textContent = 'Dashboard';
        homeMessage.textContent = `¡Bienvenido, ${AppState.user.nombre}!`;
        UI.setUserBadge(AppState.user.nombre);

        guestActions.style.display = 'none';
        authWidgets.style.display = 'grid';
        authActions.style.display = 'block';

        UI.showPage(DOM.homeSection);
        UI.setActiveMenu(DOM.menuInicio);
        updateValues();
        UI.closeSidebar();
    };

    const renderGuest = () => {
        // Usuario invitado
        DOM.menuPerfil.style.display = 'none';
        DOM.menuCalculadora.style.display = 'none';
        DOM.menuHistorico.style.display = 'none';
        DOM.btnCerrarSesion.style.display = 'none';

        btnAplicarInteres.disabled = true;
        btnReiniciar.disabled = true;

        homeTitle.textContent = 'Bienvenido a BHG Plantales';
        homeMessage.textContent = 'Inicia sesión o crea una cuenta para gestionar tu deuda.';
        UI.setUserBadge(null);

        guestActions.style.display = 'block';
        authWidgets.style.display = 'none';
        authActions.style.display = 'none';

        UI.showPage(DOM.homeSection);
        UI.setActiveMenu(DOM.menuInicio);
        updateValues();
        UI.closeSidebar();
    };

    const updateValues = () => {
        deudaDisplay.textContent = '$' + AppState.deuda.toFixed(2);
        interesDisplay.textContent = AppState.interes + '%';
        const total = AppState.deuda * (1 + AppState.interes / 100);
        totalDisplay.textContent = '$' + total.toFixed(2);
    };

    const applyInteres = () => {
        if (!AppState.user) {
            UI.showToast('⚠️ Debes iniciar sesión');
            return;
        }
        AppState.interes += 5;
        AppState.deuda = AppState.deuda * 1.05;
        updateValues();
        HistorialModule.add('📈 Interés del 5% aplicado');
        UI.showToast('✅ Interés aplicado');
    };

    const reiniciarDeuda = () => {
        if (!AppState.user) {
            UI.showToast('⚠️ Debes iniciar sesión');
            return;
        }
        AppState.deuda = 5000;
        AppState.interes = 0;
        updateValues();
        HistorialModule.add('🔄 Deuda reiniciada a $5000');
        UI.showToast('🔄 Deuda reiniciada');
    };

    const init = () => {
        btnAplicarInteres?.addEventListener('click', applyInteres);
        btnReiniciar?.addEventListener('click', reiniciarDeuda);
        DOM.menuInicio?.addEventListener('click', () => {
            UI.showPage(DOM.homeSection);
            UI.setActiveMenu(DOM.menuInicio);
            UI.closeSidebar();
        });
    };

    return { render, renderGuest, init, updateValues };
})();