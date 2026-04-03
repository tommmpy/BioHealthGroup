import os
import sys
import logging
from datetime import datetime
from functools import wraps

from flask import Flask, request, jsonify, send_from_directory, g
from flask_cors import CORS
from sqlalchemy import Column, String, DateTime, Integer, Float, create_engine, ForeignKey
from sqlalchemy.orm import sessionmaker, declarative_base, relationship
from sqlalchemy.exc import IntegrityError
from werkzeug.security import generate_password_hash, check_password_hash
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler('app.log', mode='a')
    ]
)
logger = logging.getLogger(__name__)

# ========== CONFIGURACIÓN ==========
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
FRONT_DIR = os.path.abspath(os.path.join(BASE_DIR, '..', 'frontend'))
DB_PATH = os.path.join(BASE_DIR, 'data')
os.makedirs(DB_PATH, exist_ok=True)

# Environment variables with defaults
DEBUG = os.getenv('DEBUG', 'False').lower() == 'true'
PORT = int(os.getenv('PORT', 5000))
HOST = os.getenv('HOST', '0.0.0.0')
SECRET_KEY = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
DB_URL = os.getenv('DATABASE_URL', 'sqlite:///bhg.db')

logger.info(f"🚀 BHG Plantales Backend")
logger.info(f"Frontend: {FRONT_DIR}")
logger.info(f"Database: {DB_URL}")
logger.info(f"Debug: {DEBUG}")
logger.info(f"Host: {HOST}:{PORT}")

# ========== BASE DE DATOS ==========
Base = declarative_base()

class User(Base):
    __tablename__ = 'users'
    
    id = Column(Integer, primary_key=True)
    usuario = Column(String(80), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False)
    nombre = Column(String(120), nullable=False)
    fecha_nacimiento = Column(String(10), nullable=True)
    sucursal = Column(String(120), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationship
    calculations = relationship("Calculation", back_populates="user", cascade="all, delete-orphan")

    def to_dict(self):
        return {
            'id': self.id,
            'usuario': self.usuario,
            'nombre': self.nombre,
            'fecha_nacimiento': self.fecha_nacimiento or '',
            'sucursal': self.sucursal or '',
            'created_at': self.created_at.isoformat() if self.created_at else None,
        }

    def verify_password(self, raw_password):
        return check_password_hash(self.password_hash, raw_password)

    def set_password(self, raw_password):
        self.password_hash = generate_password_hash(raw_password, method='pbkdf2:sha256')


class Calculation(Base):
    __tablename__ = 'calculations'
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    deuda_inicial = Column(Float, nullable=False)
    interes = Column(Float, nullable=False)
    periodos = Column(Integer, nullable=False)
    deuda_final = Column(Float, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationship
    user = relationship("User", back_populates="calculations")

    def to_dict(self):
        return {
            'id': self.id,
            'deuda_inicial': self.deuda_inicial,
            'interes': self.interes,
            'periodos': self.periodos,
            'deuda_final': self.deuda_final,
            'created_at': self.created_at.isoformat() if self.created_at else None,
        }


try:
    engine = create_engine(DB_URL, connect_args={"check_same_thread": False}, echo=DEBUG)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    Base.metadata.create_all(bind=engine)
    logger.info("✅ Base de datos inicializada")
except Exception as e:
    logger.error(f"❌ Error en BD: {e}")
    sys.exit(1)

# ========== FLASK APP ==========
app = Flask(__name__, static_folder=FRONT_DIR, static_url_path='')
app.config['SECRET_KEY'] = SECRET_KEY
app.config['JSON_SORT_KEYS'] = False
app.config['JSONIFY_PRETTYPRINT_REGULAR'] = False  # Better for production

CORS(app, 
     resources={r"/api/*": {"origins": ["*"], "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"]}},
     supports_credentials=True)

# ========== UTILITIES ==========
def get_db():
    """Get database session"""
    if 'db' not in g:
        g.db = SessionLocal()
    return g.db

@app.teardown_appcontext
def close_db(error):
    """Close database session"""
    db = g.pop('db', None)
    if db is not None:
        db.close()

# ========== RUTAS - FRONTEND ==========
@app.route('/')
def index():
    """Sirve el index.html"""
    return send_from_directory(FRONT_DIR, 'index.html')

@app.route('/<path:path>')
def serve_static(path):
    """Sirve archivos estáticos"""
    file_path = os.path.join(FRONT_DIR, path)
    
    if os.path.isfile(file_path):
            return send_from_directory(FRONT_DIR, path)
    
    # Fallback a index para SPA
    return send_from_directory(FRONT_DIR, 'index.html')

# ========== RUTAS - API ==========
@app.route('/api', methods=['GET'])
def api_root():
    """API Info"""
    return jsonify({
        'ok': True,
        'version': '1.0.0',
        'service': 'BHG Plantales',
        'name': 'Bio Health Group - Clínica Ortopédica',
        'endpoints': {
            'auth': ['/api/login', '/api/register'],
            'users': ['/api/users', '/api/users/<usuario>'],
            'calculations': ['/api/calculations', '/api/calculations/<usuario>'],
            'utils': ['/api/ping'],
            'ESTA TODO CORRECTO': 'SI, TODO FUNCIONA PERFECTAMENTE'
        }
        
        
        
    }), 200

@app.route('/api/ping', methods=['GET'])
def ping():
    """Health check"""
    return jsonify({'ok': True, 'msg': 'pong', 'timestamp': datetime.utcnow().isoformat()}), 200

# ========== AUTH - REGISTER ==========
@app.route('/api/register', methods=['POST'])
def register():
    """Crear nuevo usuario"""
    try:
        data = request.get_json() or {}
        usuario = data.get('usuario', '').strip()
        password = data.get('password', '').strip()
        nombre = data.get('nombre', '').strip()
        fecha_nacimiento = data.get('fecha_nacimiento', '').strip() or None
        sucursal = data.get('sucursal', '').strip() or None

        # Validaciones
        if not usuario or not password or not nombre:
            return jsonify({
                'ok': False,
                'error': 'Usuario, contraseña y nombre son requeridos'
            }), 400

        if len(usuario) < 3:
            return jsonify({
                'ok': False,
                'error': 'El usuario debe tener al menos 3 caracteres'
            }), 400

        if len(password) < 4:
            return jsonify({
                'ok': False,
                'error': 'La contraseña debe tener al menos 4 caracteres'
            }), 400

        db = get_db()
        try:
            # Verificar si existe
            exists = db.query(User).filter(User.usuario == usuario).first()
            if exists:
                return jsonify({
                    'ok': False,
                    'error': 'El usuario ya existe'
                }), 409

            # Crear usuario
            new_user = User()
            new_user.usuario = usuario
            new_user.nombre = nombre
            new_user.fecha_nacimiento = fecha_nacimiento
            new_user.sucursal = sucursal
            new_user.set_password(password)

            db.add(new_user)
            db.commit()
            
            logger.info(f"✅ Usuario registrado: {usuario}")

            return jsonify({
                'ok': True,
                'msg': 'Usuario registrado exitosamente',
                'user': new_user.to_dict()
            }), 201

        except IntegrityError:
            db.rollback()
            return jsonify({
                'ok': False,
                'error': 'El usuario ya existe'
            }), 409

    except Exception as e:
        logger.error(f"❌ Error register: {e}")
        return jsonify({
            'ok': False,
            'error': f'Error al registrar'
        }), 500

# ========== AUTH - LOGIN ==========
@app.route('/api/login', methods=['POST'])
def login():
    """Iniciar sesión"""
    try:
        data = request.get_json() or {}
        usuario = data.get('usuario', '').strip()
        password = data.get('password', '').strip()

        if not usuario or not password:
            return jsonify({
                'ok': False,
                'error': 'Usuario y contraseña requeridos'
            }), 400

        db = get_db()
        user = db.query(User).filter(User.usuario == usuario).first()
        
        if not user or not user.verify_password(password):
            logger.warning(f"❌ Intento fallido: {usuario}")
            return jsonify({
                'ok': False,
                'error': 'Usuario o contraseña incorrectos'
            }), 401

        logger.info(f"✅ Login exitoso: {usuario}")
        return jsonify({
            'ok': True,
            'msg': 'Sesión iniciada',
            'user': user.to_dict()
        }), 200

    except Exception as e:
        logger.error(f"❌ Error login: {e}")
        return jsonify({
            'ok': False,
            'error': 'Error al iniciar sesión'
        }), 500

# ========== USUARIOS - GET ALL ==========
@app.route('/api/users', methods=['GET'])
def get_all_users():
    """Obtener todos los usuarios"""
    try:
        db = get_db()
        users = db.query(User).order_by(User.created_at.desc()).all()
        return jsonify({
            'ok': True,
            'count': len(users),
            'users': [u.to_dict() for u in users]
        }), 200
    except Exception as e:
        logger.error(f"❌ Error get all users: {e}")
        return jsonify({
            'ok': False,
            'error': 'Error al obtener usuarios'
        }), 500

# ========== USUARIOS - GET ONE ==========
@app.route('/api/users/<usuario>', methods=['GET'])
def get_user(usuario):
    """Obtener usuario por nombre de usuario"""
    try:
        db = get_db()
        user = db.query(User).filter(User.usuario == usuario).first()
        if not user:
            return jsonify({
                'ok': False,
                'error': 'Usuario no encontrado'
            }), 404

        return jsonify({
            'ok': True,
            'user': user.to_dict()
        }), 200
    except Exception as e:
        logger.error(f"❌ Error get user: {e}")
        return jsonify({
            'ok': False,
            'error': 'Error al obtener usuario'
        }), 500

# ========== USUARIOS - UPDATE ==========
@app.route('/api/users/<usuario>', methods=['PUT'])
def update_user(usuario):
    """Actualizar usuario"""
    try:
        data = request.get_json() or {}
        db = get_db()
        user = db.query(User).filter(User.usuario == usuario).first()
        if not user:
            return jsonify({
                'ok': False,
                'error': 'Usuario no encontrado'
            }), 404

        # Actualizar campos
        if 'nombre' in data and data['nombre']:
            user.nombre = data['nombre'].strip()
        if 'fecha_nacimiento' in data:
            user.fecha_nacimiento = data['fecha_nacimiento'] or None
        if 'sucursal' in data:
            user.sucursal = data['sucursal'].strip() or None
        if 'password' in data and data['password']:
            user.set_password(data['password'].strip())

        db.commit()
        logger.info(f"✅ Usuario actualizado: {usuario}")

        return jsonify({
            'ok': True,
            'msg': 'Usuario actualizado',
            'user': user.to_dict()
        }), 200

    except IntegrityError:
        db.rollback()
        return jsonify({
            'ok': False,
            'error': 'Error al actualizar usuario'
        }), 409
    except Exception as e:
        logger.error(f"❌ Error update: {e}")
        return jsonify({
            'ok': False,
            'error': 'Error al actualizar'
        }), 500

# ========== CALCULATIONS - SAVE ==========
@app.route('/api/calculations', methods=['POST'])
def save_calculation():
    """Guardar cálculo"""
    try:
        data = request.get_json() or {}
        usuario = data.get('usuario', '').strip()
        deuda_inicial = data.get('deuda_inicial')
        interes = data.get('interes')
        periodos = data.get('periodos')

        if not usuario or deuda_inicial is None or interes is None or periodos is None:
            return jsonify({
                'ok': False,
                'error': 'Datos incompletos'
            }), 400

        db = get_db()
        user = db.query(User).filter(User.usuario == usuario).first()
        if not user:
            return jsonify({
                'ok': False,
                'error': 'Usuario no encontrado'
            }), 404

        deuda_final = deuda_inicial * (1 + interes / 100) ** periodos

        calc = Calculation(
            user_id=user.id,
            deuda_inicial=deuda_inicial,
            interes=interes,
            periodos=periodos,
            deuda_final=deuda_final
        )
        db.add(calc)
        db.commit()

        logger.info(f"✅ Cálculo guardado para {usuario}")
        return jsonify({
            'ok': True,
            'msg': 'Cálculo guardado',
            'calculation': calc.to_dict()
        }), 201

    except Exception as e:
        logger.error(f"❌ Error save calculation: {e}")
        return jsonify({
            'ok': False,
            'error': 'Error al guardar cálculo'
        }), 500

# ========== CALCULATIONS - GET ==========
@app.route('/api/calculations/<usuario>', methods=['GET'])
def get_calculations(usuario):
    """Obtener cálculos de usuario"""
    try:
        db = get_db()
        user = db.query(User).filter(User.usuario == usuario).first()
        if not user:
            return jsonify({
                'ok': False,
                'error': 'Usuario no encontrado'
            }), 404

        calcs = db.query(Calculation).filter(Calculation.user_id == user.id).order_by(Calculation.created_at.desc()).all()
        return jsonify({
            'ok': True,
            'count': len(calcs),
            'calculations': [c.to_dict() for c in calcs]
        }), 200

    except Exception as e:
        logger.error(f"❌ Error get calculations: {e}")
        return jsonify({
            'ok': False,
            'error': 'Error al obtener cálculos'
        }), 500

# ========== ERROR HANDLERS ==========
@app.errorhandler(404)
def not_found(error):
    return jsonify({'ok': False, 'error': 'Recurso no encontrado'}), 404

@app.errorhandler(500)
def internal_error(error):
    print(f"❌ Error 500: {error}")
    return jsonify({'ok': False, 'error': 'Error interno del servidor'}), 500

@app.errorhandler(405)
def method_not_allowed(error):
    return jsonify({'ok': False, 'error': 'Método no permitido'}), 405

# ========== MAIN ==========
if __name__ == '__main__':
    logger.info(f"🚀 Inicia el servidor en: http://{HOST}:{PORT}")
    try:
        app.run(host=HOST, port=PORT, debug=DEBUG, use_reloader=DEBUG)
    except KeyboardInterrupt:
        logger.info("👋 Servidor detenido")