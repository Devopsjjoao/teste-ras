#!/bin/bash

# ==============================================================================
# SCRIPT DE DEPLOY AUTOMATIZADO - SIMULAÇÃO JAVA EE (GSAN)
# ==============================================================================

# Definição de Variáveis
CONTAINER_NAME="gsan_app_server"
APP_DIR="/opt/gsan/app"
BACKUP_DIR="/opt/gsan/backups"
ARTIFACT_NAME="app.war"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "------------------------------------------------------------"
echo "🚀 Iniciando o pipeline de Deploy Automatizado no contêiner..."
echo "------------------------------------------------------------"

# Passo 1: Garantir que os diretórios de destino existem dentro do contêiner
echo "📁 [1/5] Verificando e criando diretórios de destino..."
docker exec $CONTAINER_NAME mkdir -p $APP_DIR $BACKUP_DIR

# Passo 2: Verificar se já existe uma versão anterior rodando (para estratégia de Rollback)
echo "🔍 [2/5] Verificando se existe uma versão anterior da aplicação..."
docker exec $CONTAINER_NAME [ -f "$APP_DIR/$ARTIFACT_NAME" ]
HAS_PREVIOUS_VERSION=$?

# Passo 3: Estratégia de Rollback - Criar backup se a versão anterior existir
if [ $HAS_PREVIOUS_VERSION -eq 0 ]; then
    echo "📦 [3/5] Versão antiga encontrada! Criando backup de segurança (Rollback Strategy)..."
    docker exec $CONTAINER_NAME cp "$APP_DIR/$ARTIFACT_NAME" "$BACKUP_DIR/app_backup_${TIMESTAMP}.war"
    echo "✔ Backup gerado com sucesso em: $BACKUP_DIR/app_backup_${TIMESTAMP}.war"
else
    echo "ℹ [3/5] Nenhuma versão anterior encontrada. Pulando etapa de backup."
fi

# Passo 4: Simular a implantação (Deploy) do novo artefato (.war)
echo "🚚 [4/5] Implantando a nova versão do artefato..."
# Em um cenário real com arquivos locais, usaríamos: docker cp ./app.war gsan_app_server:/opt/gsan/app/app.war
docker exec $CONTAINER_NAME bash -c "echo 'Versão da aplicação implantada com sucesso via Script Bash!' > $APP_DIR/$ARTIFACT_NAME"

# Passo 5: Validação de Saúde (Healthcheck) pós-deploy
echo "🔬 [5/5] Executando validação pós-deploy (Healthcheck)..."
DEPLOYED_CONTENT=$(docker exec $CONTAINER_NAME cat "$APP_DIR/$ARTIFACT_NAME")

if [ ! -z "$DEPLOYED_CONTENT" ]; then
    echo "------------------------------------------------------------"
    echo "🎉 STATUS: DEPLOY CONCLUÍDO COM SUCESSO EM PRODUÇÃO!"
    echo "📝 Conteúdo validado: \"$DEPLOYED_CONTENT\""
    echo "------------------------------------------------------------"
    exit 0
else
    echo "❌ ERRO: O artefato não pôde ser validado após o deploy."
    exit 1
fi
