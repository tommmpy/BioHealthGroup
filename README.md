# BHG Plantales - Clínica Ortopédica

Una aplicación web completa para la gestión de deudas e intereses de la Clínica Ortopédica Bio Health Group.

## 🚀 Características

- **Autenticación de usuarios**: Registro y login seguro
- **Calculadora de intereses**: Cálculo de deudas con interés compuesto
- **Dashboard interactivo**: Visualización de deuda actual y aplicación de intereses
- **Historial de movimientos**: Registro de todas las operaciones
- **Perfil de usuario**: Gestión de información personal
- **API REST**: Backend robusto con SQLAlchemy
- **Interfaz moderna**: Diseño responsive con tema oscuro

## 🛠️ Tecnologías

### Backend
- **Python 3.14+**
- **Flask** - Framework web
- **SQLAlchemy** - ORM de base de datos
- **Flask-CORS** - Manejo de CORS
- **Werkzeug** - Utilidades de seguridad

### Frontend
- **HTML5/CSS3** - Estructura y estilos
- **JavaScript (ES6+)** - Lógica del cliente
- **Fetch API** - Comunicación con backend

### Base de datos
- **SQLite** - Base de datos ligera y portable

## 📦 Instalación

### Prerrequisitos
- Python 3.14 o superior
- Navegador web moderno

### Configuración del entorno

1. **Clona el repositorio** (si aplica) o navega al directorio del proyecto

2. **Configura el entorno virtual**:
   ```bash
   cd src/backend
   python -m venv venv
   # En Windows:
   venv\Scripts\activate
   # En Linux/Mac:
   source venv/bin/activate
   ```

3. **Instala las dependencias**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Configura las variables de entorno** (opcional):
   Crea un archivo `.env` en la raíz del proyecto:
   ```env
   DEBUG=True
   PORT=5000
   HOST=0.0.0.0
   SECRET_KEY=tu-clave-secreta-aqui
   DATABASE_URL=sqlite:///src/backend/data/bhg.db
   ```

## 🚀 Ejecución

### Backend
```bash
cd src/backend
python app.py
```

El servidor se iniciará en `http://localhost:5000`

### Frontend
El frontend se sirve automáticamente desde el backend. Abre tu navegador en `http://localhost:5000`

## 📊 Uso

1. **Registro**: Crea una cuenta nueva
2. **Login**: Inicia sesión con tus credenciales
3. **Dashboard**: Visualiza tu deuda actual
4. **Calculadora**: Realiza cálculos de interés compuesto
5. **Historial**: Revisa tus movimientos guardados
6. **Perfil**: Actualiza tu información personal

## 🏗️ Arquitectura

```
bhg-plantales/
├── src/
│   ├── backend/
│   │   ├── app.py          # Servidor Flask principal
│   │   ├── requirements.txt # Dependencias Python
│   │   └── data/           # Base de datos SQLite
│   └── frontend/
│       ├── index.html      # Página principal
│       ├── styles.css      # Estilos CSS
│       └── js/             # JavaScript modular
│           ├── api.js      # Cliente API
│           ├── appstate.js # Estado de la aplicación
│           ├── auth.js     # Módulo de autenticación
│           ├── calculadora.js # Calculadora de intereses
│           ├── dashboard.js # Dashboard principal
│           ├── historial.js # Historial de movimientos
│           ├── perfil.js    # Gestión de perfil
│           ├── ui.js       # Utilidades de interfaz
│           └── main.js     # Inicialización
├── .env                    # Variables de entorno
└── README.md              # Esta documentación
```

## 🔧 API Endpoints

### Autenticación
- `POST /api/register` - Registro de usuario
- `POST /api/login` - Inicio de sesión

### Usuarios
- `GET /api/users` - Lista todos los usuarios
- `GET /api/users/<usuario>` - Obtiene usuario específico
- `PUT /api/users/<usuario>` - Actualiza usuario
- `DELETE /api/users/<usuario>` - Elimina usuario

### Cálculos
- `POST /api/calculations` - Guarda un cálculo
- `GET /api/calculations/<usuario>` - Obtiene cálculos del usuario

### Utilidades
- `GET /api` - Información de la API
- `GET /api/ping` - Health check

## 🔒 Seguridad

- Hashing de contraseñas con PBKDF2
- Validación de entrada
- Manejo de errores seguro
- Configuración de CORS apropiada
- Logging de actividades

## 📱 Responsive Design

La aplicación está optimizada para:
- Desktop (1200px+)
- Tablet (700-1199px)
- Mobile (600px-)

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 📞 Contacto

Bio Health Group - Clínica Ortopédica
- Sitio web: [bhg.clinicaortopedica.com](https://bhg.clinicaortopedica.com)
- Email: info@bhg.clinicaortopedica.com

---

Desarrollado con ❤️ para la comunidad médica