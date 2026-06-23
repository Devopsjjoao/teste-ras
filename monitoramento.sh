#!/bin/bash

# ==============================================================================
# SCRIPT DE MONITORIZAÇÃO E ALERTAS - TAREFA 2 (RAS SOLUÇÕES)
# ==============================================================================

# Configurações
CONTAINER_APP="gsan_app_server"
CONTAINER_DB="gsan_postgres"
DISK_THRESHOLD=80 # Alerta se o uso do disco passar de 80%

# URL do Webhook do Discord para Alertas (Substitua pelo seu se quiser testar ao vivo)
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1518648129229033564/1dwrrydz1UVO4agP55ox24-c-3ldtBV4VgHD_i1fQ8QyI2_WDjZyT0CFwY9mz0EBWb0l"

echo "------------------------------------------------------------"
echo "🔍 Iniciando Varredura de Saúde da Infraestrutura..."
echo "------------------------------------------------------------"

# --- 1. VERIFICAÇÃO DO SERVIÇO DA APLICAÇÃO (WildFly Simulado) ---
# Verifica se o contêiner de app está rodando e responde na pasta mapeada
docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_APP}$"
APP_STATUS=$?

if [ $APP_STATUS -ne 0 ]; then
    echo "🚨 [CRÍTICO] O contêiner da aplicação ($CONTAINER_APP) está CAÍDO!"
    PAYLOAD="{\"content\": \"🔥 **CRÍTICO - R.A.S. Alertas** 🔥\n**Serviço:** Aplicação Java (GSAN)\n**Status:** INDISPONÍVEL (Contêiner Parado)\n**Ação requerida:** Verificar logs do Docker imediatamente!\"}"
    curl -H "Content-Type: application/json" -X POST -d "$PAYLOAD" $DISCORD_WEBHOOK_URL &>/dev/null
else
    echo "✔ Aplicação ($CONTAINER_APP): ONLINE"
fi


# --- 2. VERIFICAÇÃO DO BANCO DE DADOS (PostgreSQL) ---
# Executa um 'pg_isready' dentro do contêiner do Postgres para validar a saúde do banco
docker exec $CONTAINER_DB pg_isready -U gsan_admin &>/dev/null
DB_STATUS=$?

if [ $DB_STATUS -ne 0 ]; then
    echo "🚨 [CRÍTICO] O Banco de Dados PostgreSQL está FORA DE LINHA!"
    PAYLOAD="{\"content\": \"🔥 **CRÍTICO - R.A.S. Alertas** 🔥\n**Serviço:** PostgreSQL Database\n**Status:** ERRO DE CONEXÃO\n**Risco:** Queda iminente do sistema e corrupção de dados!\"}"
    curl -H "Content-Type: application/json" -X POST -d "$PAYLOAD" $DISCORD_WEBHOOK_URL &>/dev/null
else
    echo "✔ Banco de Dados ($CONTAINER_DB): RECEPTIVO"
fi


# --- 3. VERIFICAÇÃO DE ESPAÇO EM DISCO (Preventivo) ---
# Captura a percentagem de uso do disco principal do teu Linux (Host)
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo "⚠️ [AVISO] Espaço em disco crítico: ${DISK_USAGE}% utilizado!"
    PAYLOAD="{\"content\": \"⚠️ **AVISO PREVENTIVO - R.A.S.** ⚠️\n**Métrica:** Armazenamento em Disco\n**Status:** CRÍTICO (${DISK_USAGE}% usado)\n**Risco:** Risco de travamento do PostgreSQL (DiskFull)!\"}"
    curl -H "Content-Type: application/json" -X POST -d "$PAYLOAD" $DISCORD_WEBHOOK_URL &>/dev/null
else
    echo "✔ Armazenamento em Disco: OK (${DISK_USAGE}% usado)"
fi

echo "------------------------------------------------------------"
echo "Varredura concluída."
echo "------------------------------------------------------------"
