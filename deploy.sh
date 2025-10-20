#!/bin/bash
set -e # Encerra o script se qualquer comando falhar

# --- CONFIGURAÇÕES - AJUSTE ESTAS VARIÁVEIS ---
export PROJECT_ID=""
export REGION="" # ex: us-central1
export SERVICE_NAME=""
export ARTIFACT_REPO_NAME="" # Nome do repositório no Artifact Registry
export VERSION=""

# Variáveis de Ambiente para a aplicação
export API_USER=""
export API_PASSWORD=""
export IP_HOST_MAPS="" # Os ip 'Y' separado dos hosts 'X' por dois pontos e cada grupo separado por vírgula, ex: "IP1:host1,IP2:host2" \
export API_URL=""

# --- FIM DAS CONFIGURAÇÕES ---

echo "Configurando gcloud para o projeto: $PROJECT_ID"
gcloud config set project $PROJECT_ID
gcloud config set run/region $REGION

# --- ETAPA 1: Ativar APIs Necessárias ---
echo "Ativando serviços necessários..."
gcloud services enable run.googleapis.com \
    artifactregistry.googleapis.com \
    cloudbuild.googleapis.com \
    vpcaccess.googleapis.com

# --- ETAPA 2: Criar Repositório do Artifact Registry (se não existir) ---
echo "Verificando repositório do Artifact Registry..."
if ! gcloud artifacts repositories describe $ARTIFACT_REPO_NAME --location=$REGION --quiet; then
  echo "Criando repositório '$ARTIFACT_REPO_NAME'..."
  gcloud artifacts repositories create $ARTIFACT_REPO_NAME \
    --repository-format=docker \
    --location=$REGION \
    --description="Repositório para imagens da API de teste"
fi

# --- ETAPA 3: Build e Push da Imagem Docker ---
export IMAGE_URI="${REGION}-docker.pkg.dev/${PROJECT_ID}/${ARTIFACT_REPO_NAME}/${SERVICE_NAME}:${VERSION}"
echo "Iniciando build da imagem: $IMAGE_URI"
gcloud builds submit --tag $IMAGE_URI

# --- ETAPA 4: Deploy no Cloud Run ---
echo "Fazendo deploy do serviço '$SERVICE_NAME' no Cloud Run..."
gcloud run deploy $SERVICE_NAME \
  --image=$IMAGE_URI \
  --platform=managed \
  --allow-unauthenticated \
  --port=8080 \
  --set-env-vars="API_USER=$API_USER" \
  --set-env-vars="API_PASSWORD=$API_PASSWORD" \
  --set-env-vars="IP_HOST_MAPS=$IP_HOST_MAPS" \
  --set-env-vars="API_URL=$API_URL"

SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --platform=managed --format='value(status.url)')

echo "---------------------------------------------------------"
echo "DEPLOY CONCLUÍDO COM SUCESSO!"
echo "URL do serviço: $SERVICE_URL"
echo ""
echo "Para testar, acesse via curl ou navegador:"
echo "$SERVICE_URL/test_request/[NUMERO_DA_REQUISICAO]"
echo "Exemplo: curl -v $SERVICE_URL/test_request/12345"
echo "---------------------------------------------------------"
