const DOM = {
    // MENU
    menuInicio: document.getElementById('menuInicio'),
    menuPerfil: document.getElementById('menuPerfil'),
    menuCalculadora: document.getElementById('menuCalculadora'),
    menuHistorico: document.getElementById('menuHistorico'),
    btnCerrarSesion: document.getElementById('btnCerrarSesion'),

    // SECTIONS
    loginSection: document.getElementById('loginSection'),
    registroSection: document.getElementById('registroSection'),
    homeSection: document.getElementById('homeSection'),
    perfilSection: document.getElementById('perfilSection'),
    calculadoraSection: document.getElementById('calculadoraSection'),
    historicoSection: document.getElementById('historicoSection'),

    // ELEMENTS
    userBadge: document.getElementById('userBadge'),
    userInitial: document.getElementById('userInitial'),
    userNameDisplay: document.getElementById('userNameDisplay'),
    sidebar: document.getElementById('sidebar'),
    btnToggleSidebar: document.getElementById('btnToggleSidebar'),
    app: document.getElementById('app'),
    overlay: document.getElementById('overlay'),
    toastContainer: document.getElementById('toastContainer'),
};

const UI = {
    showPage: (page) => {
        [DOM.loginSection, DOM.registroSection, DOM.homeSection, DOM.perfilSection, DOM.calculadoraSection, DOM.historicoSection]
            .forEach(sec => sec && sec.classList.remove('active'));
        if (page) page.classList.add('active');
    },

    setActiveMenu: (btn) => {
        [DOM.menuInicio, DOM.menuPerfil, DOM.menuCalculadora, DOM.menuHistorico]
            .forEach(item => item && item.classList.toggle('active', item === btn));
    },

    showToast: (message, timeout = 2500) => {
        const toast = document.createElement('div');
        toast.className = 'toast';
        toast.textContent = message;
        toast.setAttribute('role', 'status');
        DOM.toastContainer.appendChild(toast);
        setTimeout(() => toast.remove(), timeout);
    },

    setUserBadge: (nombre) => {
        if (nombre) {
            DOM.userBadge.style.display = 'flex';
            DOM.userInitial.textContent = nombre[0].toUpperCase();
            DOM.userNameDisplay.textContent = nombre;
        } else {
            DOM.userBadge.style.display = 'none';
            DOM.userInitial.textContent = '';
            DOM.userNameDisplay.textContent = '';
        }
    },

    toggleSidebar: () => {
        DOM.app.classList.toggle('collapsed');
        DOM.overlay.setAttribute('aria-hidden', !DOM.app.classList.contains('collapsed'));
    },

    closeSidebar: () => {
        DOM.app.classList.remove('collapsed');
        DOM.overlay.setAttribute('aria-hidden', 'true');
    },

    initSidebarEvents: () => {
        DOM.btnToggleSidebar?.addEventListener('click', () => UI.toggleSidebar());
        DOM.overlay?.addEventListener('click', () => {
            DOM.app.classList.remove('collapsed');
            DOM.overlay.setAttribute('aria-hidden', 'true');
        });
        window.addEventListener('resize', () => {
            if (window.innerWidth > 900) {
                DOM.app.classList.remove('collapsed');
                DOM.overlay.setAttribute('aria-hidden', 'true');
            }
        });
    }
};