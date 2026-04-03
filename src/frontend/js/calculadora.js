const CalculadoraModule = (() => {
    const form = {
        deudaInicial: document.getElementById('deudaInicialInput'),
        interes: document.getElementById('interesInput'),
        periodos: document.getElementById('periodosInput'),
        btn: document.getElementById('btnCalcular'),
        resultado: document.getElementById('resultadoCalc'),
        error: document.getElementById('errorCalc'),
    };

    const handleCalcular = () => {
        form.error.textContent = '';
        form.resultado.style.display = 'none';

        const deudaInicial = parseFloat(form.deudaInicial.value);
        const interes = parseFloat(form.interes.value);
        const periodos = parseInt(form.periodos.value, 10);

        if (isNaN(deudaInicial) || isNaN(interes) || isNaN(periodos) || periodos <= 0) {
            form.error.textContent = '❌ Ingresa valores válidos';
            return;
        }

        const r = interes / 100;
        const total = deudaInicial * Math.pow(1 + r, periodos);

        form.resultado.innerHTML = `Deuda final: <strong>$${total.toFixed(2)}</strong>`;
        form.resultado.style.display = 'block';
        HistorialModule.add(`🧮 $${deudaInicial.toFixed(2)} + ${interes}% × ${periodos} período(s) = $${total.toFixed(2)}`);
        UI.showToast('✅ Cálculo completado');

        // Save to backend if user is logged in
        if (AppState.user) {
            API.saveCalculation(AppState.user.usuario, deudaInicial, interes, periodos)
                .then(res => {
                    if (res.ok) {
                        console.log('✅ Cálculo guardado en BD');
                    } else {
                        console.warn('⚠️ No se pudo guardar el cálculo:', res.error);
                    }
                })
                .catch(err => console.error('❌ Error guardando cálculo:', err));
        }
    };

    const init = () => {
        form.btn?.addEventListener('click', handleCalcular);
        DOM.menuCalculadora?.addEventListener('click', () => {
            UI.showPage(DOM.calculadoraSection);
            UI.setActiveMenu(DOM.menuCalculadora);
            UI.closeSidebar();
        });
    };

    return { init };
})();