# 🚀 Desafio Técnico DevOps - RAS Soluções em Tecnologia

Este repositório contém a resolução do desafio técnico para a vaga de DevOps Engineer na RAS Soluções em Tecnologia. O objetivo do projeto é mitigar problemas críticos de infraestrutura enfrentados por clientes de sistemas legados e modernos, focando em **Automação de Deploy**, **Monitoramento Pró-ativo**, **Resiliência de Dados** e **Governança de TI**.

Para garantir a portabilidade e a facilidade de avaliação, todo o ecossistema foi conteinerizado utilizando **Docker** e **Docker Compose**, simulando de forma fiel um ambiente multi-serviços de produção.

---

## 🏗️ Arquitetura do Laboratório Local

O ambiente de testes simula a infraestrutura de um cliente real da RAS, composto por:
1. **`gsan_app_server`**: Servidor Linux (Ubuntu) isolado que simula o servidor de aplicação Java EE.
2. **`gsan_postgres`**: Instância dedicada do banco de dados PostgreSQL 15.
3. **`Volume Dedicado`**: Persistência de dados do PostgreSQL para evitar perda de informações.
4. **`Diretórios Mapeados`**: Sincronização em tempo real entre o host e os contêineres para gerenciamento de logs, artefatos e backups.

---

## 🛠️ Tecnologias Utilizadas

* **Bash Scripting**: Automação nativa e de baixo overhead para pipelines e rotinas internas.
* **Docker & Docker Compose**: Conteinerização e emulação de topologia de rede e microsserviços.
* **PostgreSQL (pg_dump/psql)**: Engine de banco de dados e ferramentas oficiais de disaster recovery.
* **GitHub Actions**: Orquestração de esteiras de CI/CD baseadas em eventos e tags.
* **Discord/Slack Webhooks**: Integração contínua para entrega de alertas em tempo real (ChatOps).

---

## 📂 Estrutura do Projeto

```text
teste-Ras/
├── .github/
│   └── workflows/
│       └── ci-cd.yml     # Tarefa Bônus: Pipeline de CI/CD automatizado
├── .env                  # Variáveis de ambiente globais e credenciais (SecOps)
├── docker-compose.yml    # Orquestração dos contêineres da infraestrutura
├── deploy.sh             # Tarefa 1: Script de automação de deploy com Rollback
├── monitoramento.sh      # Tarefa 2: Script de monitoramento de saúde e alertas
├── backup_postgres.sh    # Tarefa 3: Rotina de Hot Backup e política de retenção
├── restore_postgres.sh   # Tarefa 3: Script interativo de Recuperação de Desastres
├── DOCUMENTACAO_TEMPLATE.md # Tarefa 4: Template de documentação para clientes da RAS
└── target_server/        # Diretório local que simula os discos do servidor remoto
    ├── app/              # Onde os artefatos (.war) são implantados
    ├── backups/          # Backups gerados pelo pipeline de deploy
    └── backups_banco/    # Dumps compactados gerados pelo backup de dados

🚀 Como Executar o Projeto (Quick Start)
1. Pré-requisitos
Certifique-se de ter instalado em sua máquina:

Docker e Docker Compose instalados.

Permissões do seu usuário configuradas no grupo do docker (ou execute os comandos com sudo).

2. Clonar e Inicializar o Ambiente
No seu terminal, execute os comandos abaixo para subir a infraestrutura:

Bash
# Entrar no diretório do projeto
cd teste-Ras/

# Subir os contêineres em background
docker compose up -d
Verifique se os serviços subiram com sucesso executando docker compose ps.

📝 Resolução das Tarefas e Defesa Técnica
Tarefa 1 – Automação de Deploy (deploy.sh)
Abordagem: Implementação de um pipeline de deployment via CLI do Docker. O script elimina a necessidade de chaves SSH vulneráveis ou agentes pesados no contêiner.

Estratégia de Rollback: Antes de sobrescrever o artefato app.war, o script valida se o sistema já existe, gerando uma cópia de segurança com timestamp na pasta de backups. Caso ocorra uma falha, a reversão do estado leva segundos.

Execução:

Bash
chmod +x deploy.sh
./deploy.sh
Tarefa 2 – Monitoramento e Alertas (monitoramento.sh)
Abordagem: Monitoramento focado em SRE e disponibilidade de serviços.

Saúde Real vs Falsa: Em vez de apenas checar se o contêiner do banco está ligado, o script executa o comando oficial pg_isready para garantir que o Postgres está aceitando conexões.

Alerta Preventivo (DiskFull): O script analisa o consumo de disco do host e dispara um aviso preventivo antes do disco atingir 100%, mitigando o risco de corrupção de tabelas relatado pelos clientes.

ChatOps: Integração nativa com Webhooks do Discord/Slack para notificação instantânea da equipe de suporte.

Execução:

Bash
chmod +x monitoramento.sh
./monitoramento.sh
Tarefa 3 – Rotina de Backup e Recuperação (backup_postgres.sh e restore_postgres.sh)
Abordagem: Garantia de integridade e resiliência dos dados de faturamento.

Hot Backup: Utilização do pg_dump para realizar cópias consistentes sem necessidade de dar downtime na aplicação ou travar as tabelas para os usuários.

Política de Retenção (Pruning): O script aplica de forma automática um expurgo de segurança, deletando backups mais antigos que 7 dias (find -mtime +7), evitando que o armazenamento do cliente fique saturado.

Disaster Recovery: O script restore_postgres.sh fornece uma interface CLI interativa para o operador escolher qual snapshot deseja restaurar, efetuando o drop seguro do schema antigo e injeção limpa dos dados históricos.

Execução do Backup: ./backup_postgres.sh

Execução do Restore: ./restore_postgres.sh
