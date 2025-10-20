import os
import logging
import json
import urllib3
import requests
from urllib.parse import urlparse
from flask import Flask, request, jsonify
from requests.auth import HTTPBasicAuth

from .tracer import get_trace_log

# Desabilita avisos de SSL (use com cautela, apenas para ambientes de teste)
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Configuração básica de logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

app = Flask(__name__)

# Lê as configurações das variáveis de ambiente
API_USER = os.environ.get("API_USER", "user")
API_PASSWORD = os.environ.get("API_PASSWORD", "password")
IP_HOST_MAPS = os.environ.get("IP_HOST_MAPS", "")
API_URL = os.environ.get("API_URL", "https://example.com")

def get_target_ip_from_api_url(api_url):
    """
    Extrai o host do URL da API e mapeia para o IP definido na variável de ambiente IP_HOST_MAPS.
    """
    parsed_url = urlparse(api_url)
    host = parsed_url.hostname

    if not IP_HOST_MAPS:
        logging.warning("A variável de ambiente IP_HOST_MAPS não está configurada.")
        return None

    host_ip_map = dict()
    mappings = IP_HOST_MAPS.split(',')
    for mapping in mappings:
        try:
            ip, mapped_host = mapping.split(':')
            host_ip_map[mapped_host] = ip
        except ValueError:
            logging.error(f"Mapping inválido na variável IP_HOST_MAPS: {mapping}")

    target_ip = host_ip_map.get(host)
    if not target_ip:
        logging.warning(f"Nenhum mapeamento encontrado para o host: {host}")

    return target_ip

@app.route("/")
def index():
    return jsonify({"status": "ok", "message": "API de teste para Traceroute está no ar."})

@app.route("/test_request/<string:requisicao_id>", methods=['GET'])
def test_request(requisicao_id):
    """
    Endpoint que executa os testes de requisição.
    """
    if not IP_HOST_MAPS:
        return jsonify({"error": "A variável de ambiente IP_HOST_MAPS não foi configurada."}), 500

    logging.info(f"Iniciando teste para a requisição: {requisicao_id}")
    
    # URLs definidas no briefing
    urls_to_test = [
        f"{API_URL}/sap/opu/odata/sap/ZTHAIS_ODATA/ReqCompras('{requisicao_id}')/?$format=json"
    ]
    
    TARGET_IP = get_target_ip_from_api_url(API_URL)

    full_log = {
        "requisicao_id": requisicao_id,
        "target_ip_config": TARGET_IP,
        "results": []
    }

    # Executa traceroute para o IP de destino para mapear os saltos
    full_log['network_trace'] = get_trace_log(TARGET_IP)

    for url in urls_to_test:
        log_entry = {
            "url_testada": url,
            "etapa": "INICIADA"
        }
        
        try:
            logging.info(f"Executando GET para: {url}")
            
            # --- Execução da Requisição ---
            response = requests.get(
                url, 
                auth=HTTPBasicAuth(API_USER, API_PASSWORD),
                verify=False, # Desabilita a verificação do certificado SSL
                timeout=30 # Timeout de 30 segundos
            )

            logging.info(f"Recebida resposta para {url} com status {response.status_code}")

            # --- Coleta de Logs Detalhados ---
            log_entry["etapa"] = "CONCLUÍDA"
            log_entry["status_code"] = response.status_code
            log_entry["response_headers"] = dict(response.headers)
            try:
                log_entry["response_body"] = response.json()
            except json.JSONDecodeError:
                log_entry["response_body"] = response.text
            
            log_entry["request_headers"] = dict(response.request.headers)

        except requests.exceptions.RequestException as e:
            logging.error(f"Erro ao tentar acessar {url}: {e}")
            log_entry["etapa"] = "ERRO"
            log_entry["erro_details"] = str(e)

        full_log["results"].append(log_entry)

    return jsonify(full_log)

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
