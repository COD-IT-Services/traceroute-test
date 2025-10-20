# Use a imagem base oficial do Python 3.8
FROM python:3.8-slim

# Define o diretório de trabalho no container
WORKDIR /usr/src/app

# Define variáveis de ambiente para o Python
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Instala as dependências do sistema, incluindo traceroute
RUN apt-get update && apt-get install -y --no-install-recommends \
    traceroute \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instala as dependências do Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia o código da aplicação e o script de entrypoint para o container
COPY ./app /usr/src/app/app
COPY entrypoint.sh /usr/src/app/entrypoint.sh

# Garante que o script de entrypoint seja executável
RUN chmod +x /usr/src/app/entrypoint.sh

# Define o script de entrypoint que será executado quando o container iniciar
ENTRYPOINT ["/usr/src/app/entrypoint.sh"]
