# Traceroute Test

Este é um projeto de API proxy desenvolvido para facilitar a comunicação com serviços web, oferecendo uma camada intermediária de autenticação e mapeamento de IPs.

## Descrição

O projeto consiste em uma API Flask que atua como um proxy, gerenciando autenticação e redirecionamento de requisições para os serviços de destino. Ele inclui funcionalidades para mapeamento de hosts para IPs específicos e gerenciamento de credenciais através de variáveis de ambiente.

## Requisitos

- Python 3.8
- Docker
- Docker Compose

## Configuração

### Variáveis de Ambiente

O projeto utiliza as seguintes variáveis de ambiente:

- `API_USER`: Usuário para autenticação
- `API_PASSWORD`: Senha para autenticação
- `IP_HOST_MAPS`: Mapeamento de IPs para hosts (formato: "IP:host,IP:host")
- `API_URL`: URL base da API de destino
- `PORT`: Porta em que a aplicação será executada (padrão: 8080)

### Estrutura do Projeto

```
├── app/
│   ├── __init__.py
│   ├── main.py
│   └── tracer.py
├── deploy.sh
├── docker-compose.yml
├── Dockerfile
├── entrypoint.sh
└── requirements.txt
```

## Executando o Projeto

### Com Docker Compose

1. Clone o repositório
2. Execute o comando:

```bash
docker-compose up --build
```

A aplicação estará disponível em `http://localhost:8080`

### Sem Docker

1. Clone o repositório
2. Instale as dependências:

```bash
pip install -r requirements.txt
```

3. Configure as variáveis de ambiente necessárias
4. Execute a aplicação:

```bash
python app/main.py
```

## Características

- Proxy reverso para serviços web
- Mapeamento dinâmico de IPs para hosts
- Autenticação básica HTTP
- Logging configurável
- Containerização com Docker

## Segurança

⚠️ **Nota**: A aplicação desabilita avisos de SSL por padrão. Isso é recomendado apenas para ambientes de teste. Para produção, configure adequadamente os certificados SSL.

## Deploy

O projeto inclui um script de deploy (`deploy.sh`) configurado para implantação automatizada no Google Cloud Platform (GCP) usando Cloud Run. 

### Pré-requisitos para Deploy

- Conta GCP com billing ativado
- Google Cloud SDK (gcloud) instalado e configurado
- Permissões necessárias no projeto GCP:
  - Cloud Run Admin
  - Artifact Registry Admin
  - Cloud Build Editor

### Configuração do Deploy

Antes de executar o script, configure as variáveis no início do arquivo `deploy.sh`:

```bash
# Configurações do GCP
export PROJECT_ID=""      # ID do projeto no GCP
export REGION=""          # Região (ex: us-central1)
export SERVICE_NAME=""    # Nome do serviço no Cloud Run
export ARTIFACT_REPO_NAME="" # Nome do repositório no Artifact Registry
export VERSION=""         # Versão do deploy

# Variáveis de ambiente da aplicação
export API_USER=""        # Usuário para autenticação
export API_PASSWORD=""    # Senha para autenticação
export IP_HOST_MAPS=""    # Formato: "IP1:host1,IP2:host2"
export API_URL=""         # URL base da API
```

### Executando o Deploy

1. Dê permissão de execução ao script:
```bash
chmod +x deploy.sh
```

2. Execute o script:
```bash
./deploy.sh
```

### O que o Script Faz

1. Configura o projeto GCP e região
2. Ativa as APIs necessárias (Cloud Run, Artifact Registry, Cloud Build)
3. Cria ou verifica o repositório no Artifact Registry
4. Realiza o build e push da imagem Docker
5. Faz o deploy no Cloud Run com as variáveis de ambiente configuradas

Após a conclusão, o script exibirá a URL do serviço e um exemplo de como testá-lo.

## Desenvolvido por

<♦> COD IT Services