# 📄 [TEMPLATE] Documentação de Ambiente de Cliente - R.A.S.

## 1. Identificação do Cliente
* **Nome do Cliente:** [Nome da Empresa / Município]
* **Ambiente:** [ ] Produção  [ ] Homologação  [ ] Desenvolvimento
* **Responsável Técnico Comercial:** [Nome do Gestor de Conta]
* **Ponto de Contacto Principal (Cliente):** [Nome - Cargo - Email/Telefone]
* **Última Atualização:** DD/MM/AAAA por [Teu Nome/Utilizador]

---

## 2. Topologia e Arquitetura de Rede
* **Provedor de Infraestrutura / Hosting:** [ex: Google Cloud, AWS, Servidor Local, Hostgator]
* **IP Público Principal:** `000.000.000.000`
* **IP Privado / Subrede:** `10.0.0.0/24`
* **Domínio Oficial:** `sistema.cliente.com.br`

### 🔑 Portas Liberadas e Firewalls
| Serviço | Porta Externa | Porta Interna | Origem Permitida | Estado |
| :--- | :--- | :--- | :--- | :--- |
| SSH | `22` (ou personalizada) | `22` | IP da VPN da RAS | Ativo |
| Aplicação (WildFly/HTTP) | `80` / `443` | `8080` | Qualquer (Internet) | Ativo |
| Banco de Dados (Postgres) | `5432` | `5432` | Apenas Local/App Server | Bloqueado Externo |

---

## 3. Inventário de Recursos (Hardware/Instância)
* **Sistema Operativo:** Ubuntu 22.04 LTS (x86_64)
* **Processamento (vCPU):** 4 vCPUs
* **Memória RAM:** 8 GB
* **Armazenamento:** 100 GB SSD (Disco Principal `/`)

---

## ⚙️ 4. Serviços em Execução Detalhados

### 🏢 Camada de Aplicação (WildFly / Servidor Web)
* **Diretório do Binário:** `/opt/wildfly/standalone/deployments/`
* **Nome do Serviço no Systemd:** `wildfly.service`
* **Comandos de Gerenciamento:**
  ```bash
  sudo systemctl status wildfly
  sudo systemctl restart wildfly
Caminho dos Logs Principais: /opt/wildfly/standalone/log/server.log

🗄️ Camada de Banco de Dados (PostgreSQL)
Versão: PostgreSQL 15

String de Conexão Local: postgresql://gsan_admin@localhost:5432/gsan_production

Nome do Serviço no Systemd: postgresql.service

Caminho dos Dados (Data Directory): /var/lib/postgresql/15/main/

💾 5. Estratégia de Backup e Monitorização
Rotina de Backup: Executada diariamente às 02h00 via script backup_postgres.sh.

Retenção: 7 dias locais.

Ferramenta de Alerta: Script nativo de healthcheck integrado ao Discord Webhook via Crontab rodando a cada 5 minutos.
