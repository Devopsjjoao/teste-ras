#!/bin/bash

# ==============================================================================
# SCRIPT DE BACKUP AUTOMATIZADO E RETENÇÃO - TAREFA 3 (POSTGRESQL)
# ==============================================================================

# Carregar variáveis do arquivo .env local se ele existir
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
fi

# Configurações
CONTAINER_DB="gsan_postgres"
DB_USER=${DB_USER:-"gsan_admin"}
DB_NAME=${DB_NAME:-"gsan_production"}

LOCAL_BACKUP_DIR="./target_server/backups_banco"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$LOCAL_BACKUP_DIR/backup_${DB_NAME}_${TIMESTAMP}.sql"
RETENCAO_DIAS=7

echo "------------------------------------------------------------"
echo "💾 Iniciando Rotina de Backup Automatizada (PostgreSQL)..."
echo "------------------------------------------------------------"

# Passo 1: Garantir que o diretório local de backups existe
mkdir -p $LOCAL_BACKUP_DIR

# Passo 2: Executar o pg_dump de dentro do contêiner jogando para a pasta local
echo "📦 [1/3] Extraindo dados do banco '$DB_NAME' via pg_dump..."
docker exec -e PGPASSWORD="$DB_PASSWORD" $CONTAINER_DB pg_dump -U $DB_USER $DB_NAME > $BACKUP_FILE

if [ $? -eq 0 ] && [ -s $BACKUP_FILE ]; then
    echo "✔ Dump gerado com sucesso!"
    
    # Passo 3: Compactar o arquivo para otimizar armazenamento
    echo "🗜️ [2/3] Compactando arquivo de backup..."
    gzip -f $BACKUP_FILE
    echo "✔ Arquivo final gerado: ${BACKUP_FILE}.gz"
    
    # Passo 4: Aplicar Política de Retenção (Apagar arquivos mais velhos que X dias)
    echo "🧹 [3/3] Aplicando política de retenção (Removendo backups com mais de $RETENCAO_DIAS dias)..."
    # Procura arquivos .sql.gz modificados há mais de 7 dias nesta pasta e apaga
    find $LOCAL_BACKUP_DIR -name "backup_${DB_NAME}_*.sql.gz" -mtime +$RETENCAO_DIAS -exec rm {} \;
    echo "✔ Limpeza de rotina concluída."
    
    echo "------------------------------------------------------------"
    echo "🎉 STATUS: BACKUP REALIZADO E SEGURO!"
    echo "------------------------------------------------------------"
else
    echo "❌ ERRO CRÍTICO: Falha ao gerar o dump do banco de dados."
    rm -f $BACKUP_FILE
    exit 1
fi
