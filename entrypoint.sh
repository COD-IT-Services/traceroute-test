#!/bin/bash
set -e

# --- Configuração do /etc/hosts ---

# A variável IP_HOST_MAPS deve ser uma string no formato: "IP_1:HOST_1,IP_2:HOST_2"

if [ -z "$IP_HOST_MAPS" ]; then
  echo "AVISO: A variável IP_HOST_MAPS não foi definida. O arquivo /etc/hosts não será modificado."
else
  echo "Configurando /etc/hosts com base em IP_HOST_MAPS..."
  
  # Converte a string de mapeamentos (separada por vírgula) em um array
  # Ex: ["IP_1:HOST_1", "IP_2:HOST_2"]
  IFS=',' read -r -a MAP_ARRAY <<< "$IP_HOST_MAPS"
  
  # Itera sobre cada mapeamento (IP:HOST)
  for map_entry in "${MAP_ARRAY[@]}"
  do
    # Remove espaços em branco (trim)
    map_entry=$(echo "$map_entry" | xargs)
    
    # Verifica se o formato IP:HOST é válido
    if [[ "$map_entry" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:.+ ]]; then
      
      # Divide o mapeamento (IP:HOST) usando o delimitador ':'
      IP=$(echo "$map_entry" | cut -d ':' -f 1)
      HOST=$(echo "$map_entry" | cut -d ':' -f 2)
      
      # Adiciona ao arquivo /etc/hosts
      echo "$IP $HOST" >> /etc/hosts
      echo "Adicionado ao hosts: '$IP $HOST'"
    else
      echo "AVISO: O mapeamento '$map_entry' foi ignorado, pois o formato não é válido (esperado: IP:HOST)."
    fi
  done

  echo "--- Conteúdo final do /etc/hosts ---"
  cat /etc/hosts
  echo "-----------------------------------"
fi

# --- Inicia a Aplicação ---
# Executa o servidor Gunicorn (padrão de produção para Flask)
# A variável PORT é fornecida automaticamente pelo Cloud Run
echo "Iniciando a aplicação com Gunicorn..."
exec gunicorn --bind 0.0.0.0:$PORT --workers 1 --threads 8 --timeout 0 "app.main:app"