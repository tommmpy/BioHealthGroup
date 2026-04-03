# BHG Plantales - Backend API

## Instalación

```bash
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
pip install -r requirements.txt
```

## Uso

```bash
python app.py
```

El servidor se ejecuta en http://localhost:5000 por defecto.

## Notas

- Si prefiere cmd.exe, use el script `run.bat`.
- Si prefiere PowerShell automation, use `setup_and_run.ps1`.
- El frontend `script.js` intentará el backend en http://localhost:5000 y caerá en localStorage si el servidor no está disponible.

## Seguridad

- Este es un pequeño backend demo. Para producción, agregue políticas de contraseña segura, HTTPS, autenticación basada en token (JWT), validación de entrada, límite de velocidad, y migraciones de DB apropiadas.
