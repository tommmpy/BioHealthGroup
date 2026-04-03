const AppState = (() => {
    let user = null;
    let deuda = 5000;
    let interes = 0;

    const setUser = (userData) => {
        user = userData;
        localStorage.setItem('bhgPlantalesCurrentUser', JSON.stringify(user));
    };

    const clearUser = () => {
        user = null;
        deuda = 5000;
        interes = 0;
        localStorage.removeItem('bhgPlantalesCurrentUser');
    };

    const restoreUser = () => {
        const stored = localStorage.getItem('bhgPlantalesCurrentUser');
        if (stored) {
            try {
                user = JSON.parse(stored);
            } catch (e) {
                localStorage.removeItem('bhgPlantalesCurrentUser');
            }
        }
    };

    return {
        get user() { return user; },
        get deuda() { return deuda; },
        set deuda(val) { deuda = val; },
        get interes() { return interes; },
        set interes(val) { interes = val; },
        setUser,
        clearUser,
        restoreUser
    };
})();