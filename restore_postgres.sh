#!/bin/bash

# ==============================================================================
# SCRIPT DE RECUPERAÇÃO DE DADOS (RESTORE) - TAREFA 3
# ==============================================================================

if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
fi

CONTAINER_DB="gsan_postgres"
DB_USER=${DB_USER:-"gsan_admin"}
DB_NAME=${DB_NAME:-"gsan_production"}
LOCAL_BACKUP_DIR="./target_server/backups_banco"

echo "------------------------------------------------------------"
echo "🚨 INICIANDO PROCEDIMENTO DE RECUPERAÇÃO DE DESASTRES (RESTORE) 🚨"
echo "------------------------------------------------------------"

# Listar backups disponíveis
echo "🔍 Arquivos de backup encontrados no servidor:"
FILE_LIST=($(ls $LOCAL_BACKUP_DIR/*.sql.gz 2>/dev/null))

if [ ${#FILE_LIST[@]} -eq 0 ]; then
    echo "❌ Nenhum arquivo de backup disponível em $LOCAL_BACKUP_DIR"
    exit 1
fi

# Mostra as opções para o operador de infraestrutura escolher
for i in "${!FILE_LIST[@]}"; do
    echo "[$i] $(basename ${FILE_LIST[$i]})"
done

echo ""
read -p "Digite o número do backup que deseja restaurar: " SELECAO

ARQUIVO_ESCOLHIDO=${FILE_LIST[$SELECAO]}

if [ -z "$ARQUIVO_ESCOLHIDO" ]; then
    echo "❌ Seleção inválida."
    exit 1
fi

echo "⚠️  ATENÇÃO: Isto irá sobrescrever o banco atual '$DB_NAME'. Continuar? (y/n)"
read -p "> " CONFIRMACAO

if [ "$CONFIRMACAO" != "y" ]; then
    echo "❌ Operação cancelada pelo usuário."
    exit 0
fi

echo "🔄 [1/2] Descompactando o arquivo temporariamente..."
gunzip -c $ARQUIVO_ESCOLHIDO > "$LOCAL_BACKUP_DIR/temp_restore.sql"

echo "🎯 [2/2] Injetando dados no contêiner PostgreSQL..."
# Dropa e recria o schema público para garantir um restore limpo
docker exec -i $CONTAINER_DB psql -U $DB_USER -d $DB_NAME -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;" &>/dev/null

# Executa o restore
docker exec -i -e PGPASSWORD="$DB_PASSWORD" $CONTAINER_DB psql -U $DB_USER -d $DB_NAME < "$LOCAL_BACKUP_DIR/temp_restore.sql" > /dev/null

if [ $? -eq 0 ]; then
    echo "------------------------------------------------------------"
    echo "🎉 SUCESSO: Banco de dados restaurado para o estado de: $(basename $ARQUIVO_ESCOLHIDO)"
    echo "------------------------------------------------------------"
else
    echo "❌ ERRO: Falha catastrófica durante a restauração."
fi

# Limpa o lixo temporário
rm -f "$LOCAL_BACKUP_DIR/temp_restore.sql"
