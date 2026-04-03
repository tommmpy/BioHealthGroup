const HistorialModule = (() => {
    const container = document.getElementById('historialLista');

    const add = (evento) => {
        const now = new Date().toLocaleString('es-ES');
        const item = document.createElement('p');
        item.className = 'historial-item';
        item.innerHTML = `<strong>${now}:</strong> ${evento}`;

        const existing = container.querySelector('.text-muted');
        if (existing) {
            container.innerHTML = '';
        }
        container.prepend(item);
    };

    const clear = () => {
        container.innerHTML = '<p class="text-muted">No hay movimientos aún.</p>';
    };

    const loadFromBackend = async () => {
        if (!AppState.user) return;
        try {
            const res = await API.getCalculations(AppState.user.usuario);
            if (res.ok && res.calculations) {
                res.calculations.forEach(calc => {
                    const date = new Date(calc.created_at).toLocaleString('es-ES');
                    add(`🧮 $${calc.deuda_inicial.toFixed(2)} + ${calc.interes}% × ${calc.periodos} período(s) = $${calc.deuda_final.toFixed(2)} (guardado)`);
                });
            }
        } catch (err) {
            console.error('❌ Error loading calculations:', err);
        }
    };

    const init = () => {
        DOM.menuHistorico?.addEventListener('click', () => {
            UI.showPage(DOM.historicoSection);
            UI.setActiveMenu(DOM.menuHistorico);
            UI.closeSidebar();
            // Load calculations when viewing history
            loadFromBackend();
        });
    };

    return { add, clear, init };
})();