import os
import json
import datetime
from flask import Flask, send_from_directory, request, redirect, jsonify, abort, render_template
from flask_cors import CORS
from dotenv import load_dotenv

# Carregar variáveis de ambiente
load_dotenv()

app = Flask(__name__, 
            static_folder='static',
            template_folder='templates')
CORS(app)  # Habilitar CORS para todas as rotas

# Configuração para armazenar dados
DATA_DIR = 'data'
BACKUPS_DIR = os.path.join(DATA_DIR, 'backups')
DATABASE_FILE = os.path.join(DATA_DIR, 'pericias.json')

# Garantir que os diretórios existam
os.makedirs(DATA_DIR, exist_ok=True)
os.makedirs(BACKUPS_DIR, exist_ok=True)

# Inicializar ou carregar o banco de dados
def load_database():
    if os.path.exists(DATABASE_FILE):
        with open(DATABASE_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {"pericias": [], "configuracoes": {}}

def save_database(data):
    with open(DATABASE_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    return True

# Criar banco de dados inicial se não existir
if not os.path.exists(DATABASE_FILE):
    initial_data = {
        "pericias": [],
        "configuracoes": {
            "nome_perito": "Dr. Adiel",
            "especialidade": "Médico Perito",
            "ultima_atualizacao": datetime.datetime.now().isoformat()
        }
    }
    save_database(initial_data)

# Configurar cache para melhorar o desempenho
@app.after_request
def add_header(response):
    if 'Cache-Control' not in response.headers:
        if request.path.endswith('.html'):
            # Não armazenar HTML em cache
            response.headers['Cache-Control'] = 'no-cache, no-store'
        elif request.path.endswith(('.js', '.css')):
            # Cache de 1 semana para recursos JS/CSS
            response.headers['Cache-Control'] = 'public, max-age=604800'
        elif request.path.endswith(('.jpg', '.jpeg', '.png', '.gif', '.ico')):
            # Cache de 1 mês para imagens
            response.headers['Cache-Control'] = 'public, max-age=2592000'
    return response

# Rota principal para a interface do usuário
@app.route('/')
def index():
    return render_template('index.html')

# Rota para o dashboard
@app.route('/dashboard')
def dashboard():
    return render_template('dashboard.html')

# API para listar pericias
@app.route('/api/pericias', methods=['GET'])
def get_pericias():
    db = load_database()
    return jsonify(db["pericias"])

# API para adicionar uma pericia
@app.route('/api/pericias', methods=['POST'])
def add_pericia():
    try:
        db = load_database()
        pericia = request.json
        
        # Adicionar ID se não existir
        if 'id' not in pericia:
            existing_ids = [p.get('id', 0) for p in db["pericias"]]
            next_id = max(existing_ids, default=0) + 1
            pericia['id'] = next_id
        
        # Adicionar data de criação
        if 'data_criacao' not in pericia:
            pericia['data_criacao'] = datetime.datetime.now().isoformat()
        
        db["pericias"].append(pericia)
        save_database(db)
        
        return jsonify({"success": True, "pericia": pericia}), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# API para atualizar uma pericia
@app.route('/api/pericias/<int:pericia_id>', methods=['PUT'])
def update_pericia(pericia_id):
    try:
        db = load_database()
        
        for i, pericia in enumerate(db["pericias"]):
            if pericia.get('id') == pericia_id:
                updated_pericia = request.json
                updated_pericia['id'] = pericia_id  # Garantir que o ID não mude
                updated_pericia['data_atualizacao'] = datetime.datetime.now().isoformat()
                
                db["pericias"][i] = updated_pericia
                save_database(db)
                
                return jsonify({"success": True, "pericia": updated_pericia})
        
        return jsonify({"success": False, "error": "Perícia não encontrada"}), 404
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# API para excluir uma pericia
@app.route('/api/pericias/<int:pericia_id>', methods=['DELETE'])
def delete_pericia(pericia_id):
    try:
        db = load_database()
        
        for i, pericia in enumerate(db["pericias"]):
            if pericia.get('id') == pericia_id:
                deleted_pericia = db["pericias"].pop(i)
                save_database(db)
                
                return jsonify({"success": True, "deleted": deleted_pericia})
        
        return jsonify({"success": False, "error": "Perícia não encontrada"}), 404
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# API para obter configurações
@app.route('/api/configuracoes', methods=['GET'])
def get_configuracoes():
    db = load_database()
    return jsonify(db["configuracoes"])

# API para atualizar configurações
@app.route('/api/configuracoes', methods=['PUT'])
def update_configuracoes():
    try:
        db = load_database()
        novas_configuracoes = request.json
        
        # Atualizar configurações existentes
        db["configuracoes"].update(novas_configuracoes)
        db["configuracoes"]["ultima_atualizacao"] = datetime.datetime.now().isoformat()
        
        save_database(db)
        
        return jsonify({"success": True, "configuracoes": db["configuracoes"]})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# Rota para verificar status do servidor
@app.route('/api/status')
def status():
    return jsonify({
        "status": "online",
        "version": "1.0.0",
        "nome_sistema": "AssistPericias Pro",
        "serverTime": datetime.datetime.now().isoformat()
    })

# API para backup de dados
@app.route('/api/backup', methods=['POST'])
def backup_data():
    api_key = os.environ.get('API_KEY', '12345')
    
    if request.headers.get('Authorization') != f"Bearer {api_key}":
        abort(401)
    
    try:
        # Fazer backup do banco de dados atual
        db = load_database()
        
        # Criar nome do arquivo de backup com timestamp
        timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        backup_file = os.path.join(BACKUPS_DIR, f"backup_{timestamp}.json")
        
        # Salvar backup
        with open(backup_file, 'w', encoding='utf-8') as f:
            json.dump(db, f, ensure_ascii=False, indent=2)
            
        return jsonify({"success": True, "message": "Backup realizado com sucesso", "file": backup_file})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# API para restaurar backup
@app.route('/api/restore/<filename>', methods=['POST'])
def restore_backup(filename):
    api_key = os.environ.get('API_KEY', '12345')
    
    if request.headers.get('Authorization') != f"Bearer {api_key}":
        abort(401)
    
    try:
        backup_file = os.path.join(BACKUPS_DIR, filename)
        
        if not os.path.exists(backup_file):
            return jsonify({"success": False, "error": "Arquivo de backup não encontrado"}), 404
        
        # Carregar dados do backup
        with open(backup_file, 'r', encoding='utf-8') as f:
            backup_data = json.load(f)
            
        # Salvar no banco de dados atual
        save_database(backup_data)
            
        return jsonify({"success": True, "message": "Backup restaurado com sucesso"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# Listar backups disponíveis
@app.route('/api/backups', methods=['GET'])
def list_backups():
    try:
        backups = []
        
        for filename in os.listdir(BACKUPS_DIR):
            if filename.startswith("backup_") and filename.endswith(".json"):
                file_path = os.path.join(BACKUPS_DIR, filename)
                file_stat = os.stat(file_path)
                
                backups.append({
                    "filename": filename,
                    "size": file_stat.st_size,
                    "created": datetime.datetime.fromtimestamp(file_stat.st_ctime).isoformat()
                })
        
        # Ordenar por data de criação (mais recente primeiro)
        backups.sort(key=lambda x: x["created"], reverse=True)
        
        return jsonify(backups)
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# Iniciar o servidor
if __name__ == '__main__':
    port = int(os.environ.get("PORT", 8080))
    debug_mode = os.environ.get("FLASK_ENV", "production") == "development"
    app.run(host='0.0.0.0', port=port, debug=debug_mode)
