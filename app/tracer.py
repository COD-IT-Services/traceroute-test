import subprocess
import logging

def get_trace_log(hostname):
    """
    Executa um traceroute para o host/IP de destino e retorna o output.
    """
    logging.info(f"Executando traceroute para o destino: {hostname}")
    try:
        # Usamos '-n' para não resolver nomes de IP, o que é mais rápido e direto
        # Usamos '-w 2' para esperar no máximo 2 segundos por resposta de cada salto
        result = subprocess.run(
            ['traceroute', '-n', '-w', '2', hostname],
            capture_output=True,
            text=True,
            timeout=60 # Timeout total para o comando
        )
        if result.returncode == 0:
            logging.info(f"Traceroute para {hostname} concluído com sucesso.")
            return {
                "status": "success",
                "output": result.stdout
            }
        else:
            logging.warning(f"Traceroute para {hostname} finalizado com erro (código: {result.returncode}).")
            return {
                "status": "error",
                "output": result.stderr
            }
            
    except FileNotFoundError:
        logging.error("O comando 'traceroute' não foi encontrado. Certifique-se de que ele está instalado no container.")
        return {
            "status": "error",
            "output": "Comando 'traceroute' não encontrado."
        }
    except Exception as e:
        logging.error(f"Uma exceção ocorreu ao executar o traceroute: {e}")
        return {
            "status": "error",
            "output": str(e)
        }
