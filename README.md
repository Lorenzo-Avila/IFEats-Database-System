# 🍽️ IFEats — Sistema de Gestão de Refeitório

<div align="center">

![SQL Server](https://img.shields.io/badge/SQL%20Server-2019%2B-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![T-SQL](https://img.shields.io/badge/T--SQL-100%25-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Concluído-brightgreen?style=for-the-badge)

**Banco de dados relacional projetado para resolver problemas reais de desperdício alimentar e gestão de demanda em refeitórios institucionais.**

[📂 Explorar Scripts](#-organização-do-repositório) · [⚡ Restaurar Banco](#-como-restaurar-o-banco-de-dados) · [📊 Módulos](#-módulos-do-sistema)

</div>

---

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [O Problema que o IFEats Resolve](#-o-problema-que-o-ifEats-resolve)
- [Arquitetura e Módulos](#-módulos-do-sistema)
- [Tecnologias e Conceitos Aplicados](#️-tecnologias-e-conceitos-aplicados)
- [Organização do Repositório](#-organização-do-repositório)
- [Pré-requisitos](#-pré-requisitos)
- [Como Restaurar o Banco de Dados](#-como-restaurar-o-banco-de-dados)
- [Como Executar do Zero](#-como-executar-do-zero-via-scripts)
- [Destaques Técnicos](#-destaques-técnicos)
- [Modelo Relacional](#-modelo-relacional)
- [Autor](#-autor)

---

## 🎯 Visão Geral

O **IFEats** é um ecossistema de banco de dados desenvolvido em **Microsoft SQL Server** para a gestão completa do refeitório do **Instituto Federal Farroupilha (IFFar)**. O projeto simula um ambiente de produção real, abrangendo desde a modelagem relacional e carga de dados até automação de regras de negócio, camadas analíticas para BI e estratégias de otimização de performance.

O sistema integra três atores principais: **administração do refeitório**, **alunos** e **cardápio semanal**conectando esses domínios com lógica de agendamento, controle de presença e rastreabilidade de alterações.

---

## 🚨 O Problema que o IFEats Resolve

Refeitórios institucionais enfrentam desafios operacionais crônicos que resultam em **desperdício de alimentos**, **custos desnecessários** e **insatisfação dos usuários**:

| Problema Real | Solução no IFEats |
|---|---|
| Preparo de refeições sem estimativa real de demanda | Relatórios de agendamentos por período via `Views` de BI |
| Alunos que agendam e não comparecem (no-show) | Índice de Penalidade com cálculo exponencial por faltas |
| Ausência de histórico de alterações em registros críticos | `Triggers AFTER` com tabelas de log para auditoria completa |
| Exclusão acidental de dados ativos | `Triggers INSTEAD OF` implementando *Soft Delete* |
| Consultas lentas em grandes volumes por data | Índices `CLUSTERED` por data e índices compostos para filtros frequentes |

---

## 📦 Módulos do Sistema

O projeto é dividido em **quatro módulos independentes e progressivos**, cada um representado por um script numerado:

### Módulo 1 — Estrutura e Dados (`01_setup_e_populacao.sql`)
> **DDL / DML**

Responsável pela fundação do banco. Cria todas as tabelas com constraints de integridade referencial, tipos de dados adequados e popula o ambiente com dados de teste representativos.

- Criação e recriação limpa do banco (`DROP IF EXISTS`)
- Definição de chaves primárias, estrangeiras e `CHECK constraints`
- Inserção de dados de alunos, cardápios, agendamentos e avaliações

---

### Módulo 2 — Analytics e BI (`02_analytics_e_bi.sql`)
> **Views · Joins Complexos · UDFs**

Camada analítica pronta para consumo por ferramentas de BI como Power BI ou Tableau. Expõe KPIs estratégicos para a gestão do refeitório sem expor a complexidade das queries aos usuários finais.

**Views implementadas:**
- Taxa de ocupação por turno e dia da semana
- Ranking de popularidade de pratos
- Taxa de no-show por aluno e por período
- Análise de satisfação via avaliações

**UDFs (User-Defined Functions):**
- Cálculo do Índice de Penalidade por faltas acumuladas
- Classificação de risco de desperdício por refeição

---

### Módulo 3 — Automação (`03_automacao_e_regras.sql`)
> **Stored Procedures · Triggers · Transações**

Encapsula a lógica de negócio no servidor, garantindo que as regras sejam aplicadas de forma consistente independentemente do cliente que acessa o banco.

**Stored Procedures:**
- `sp_RealizarAgendamento` — valida disponibilidade, registra o agendamento e atualiza contadores em uma transação atômica
- `sp_RegistrarCheckin` — processa a presença do aluno com tratamento de erros e rollback automático

**Triggers:**
- `trg_Audit_Agendamentos` — `AFTER UPDATE/DELETE`: grava um snapshot do registro alterado em tabela de log com timestamp e usuário
- `trg_SoftDelete_Alunos` — `INSTEAD OF DELETE`: substitui a exclusão física pela inativação lógica do registro (`ativo = 0`)

---

### Módulo 4 — Performance (`04_performance.sql`)
> **Índices Clusterizados · Índices Compostos**

Estratégia de indexação customizada para suportar os padrões de acesso mais comuns do sistema com o menor custo de I/O possível.

- Recriação de índice `CLUSTERED` por coluna de data em tabelas de agendamento (acesso cronológico predominante)
- Índices `NONCLUSTERED` compostos para filtros frequentes de `(aluno_id, data, status)`
- Análise do impacto antes/depois com `SET STATISTICS IO ON`

---

## 🛠️ Tecnologias e Conceitos Aplicados

- **SGBD:** Microsoft SQL Server 2019+
- **Linguagem:** T-SQL (Transact-SQL)
- **Ferramenta:** SQL Server Management Studio (SSMS) 18+

| Categoria | Técnicas |
|---|---|
| Modelagem | Normalização, constraints de integridade, relacionamentos N:N |
| Consultas | `INNER/LEFT JOIN` multi-tabela, subqueries correlacionadas, `CTEs` |
| Programabilidade | `Stored Procedures` com `TRY/CATCH` e controle transacional |
| Automação | `Triggers AFTER` (auditoria) e `INSTEAD OF` (Soft Delete) |
| Funções | `UDFs` escalares e de tabela para cálculo de KPIs |
| Performance | Índices `CLUSTERED` e `NONCLUSTERED` compostos |
| BI | `Views` gerenciais com métricas agregadas |

---

## 📂 Organização do Repositório

```
IFEats-Database-System/
│
├── 📁 docs/
│   ├── cenario-proposto.pdf         # Regras de negócio e requisitos funcionais
│   └── diagrama-relacional.png      # Diagrama Entidade-Relacionamento (DER)
│
├── 📁 scripts/
│   ├── 01_setup_e_populacao.sql     # DDL + DML: criação de tabelas e dados de teste
│   ├── 02_analytics_e_bi.sql        # Views, UDFs e consultas gerenciais
│   ├── 03_automacao_e_regras.sql    # Stored Procedures, Triggers e Transações
│   └── 04_performance.sql           # Estratégia de indexação customizada
│
├── 📁 backup/
│   └── IFEats-FullBackup.bak        # Backup completo para restauração imediata
│
└── README.md
```

> **Convenção de nomenclatura:** Os scripts são numerados para indicar a **ordem de execução recomendada**. Cada arquivo pode ser executado de forma isolada após o `01_setup` ter sido rodado ao menos uma vez.

---

## ✅ Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- [SQL Server 2019 ou superior](https://www.microsoft.com/pt-br/sql-server/sql-server-downloads) (Express, Developer ou superior)
- [SQL Server Management Studio (SSMS) 18+](https://learn.microsoft.com/pt-br/sql/ssms/download-sql-server-management-studio-ssms)
- Permissões de `sysadmin` ou `dbcreator` na instância de destino

---

## 🔧 Como Restaurar o Banco de Dados

Esta é a forma mais rápida de ter o ambiente completo funcional, incluindo estrutura e dados de exemplo.

**1. Faça o download do arquivo de backup:**

```
backup/IFEats-FullBackup.bak
```

**2. Execute o comando RESTORE no SSMS** (ajuste os caminhos conforme sua instância):

```sql
USE master;
GO

RESTORE DATABASE IFEats
FROM DISK = 'C:\caminho\para\IFEats-FullBackup.bak'
WITH
    MOVE 'IFEats'      TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\IFEats.mdf',
    MOVE 'IFEats_log'  TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\IFEats_log.ldf',
    REPLACE,           -- Sobrescreve se o banco já existir
    STATS = 10;        -- Exibe progresso a cada 10%
GO
```

> ⚠️ **Atenção:** Os caminhos após `MOVE` devem apontar para o diretório `DATA` da sua instância do SQL Server. Para localizar o caminho correto, execute:
> ```sql
> SELECT physical_name FROM sys.master_files WHERE database_id = DB_ID('master');
> ```

**3. Verifique a restauração:**

```sql
SELECT name, state_desc FROM sys.databases WHERE name = 'IFEats';
-- Esperado: ONLINE
```

---

## ▶️ Como Executar do Zero (via Scripts)

Caso prefira construir o banco a partir dos scripts, execute-os **na ordem indicada** em uma nova Query no SSMS:

```sql
-- Passo 1: Cria o banco, tabelas e popula com dados de exemplo
-- (Inclui DROP + CREATE para ambiente limpo)
:r C:\caminho\scripts\01_setup_e_populacao.sql

-- Passo 2: Cria as Views e UDFs analíticas
:r C:\caminho\scripts\02_analytics_e_bi.sql

-- Passo 3: Cria Stored Procedures e Triggers
:r C:\caminho\scripts\03_automacao_e_regras.sql

-- Passo 4: Aplica a estratégia de indexação
:r C:\caminho\scripts\04_performance.sql
```

> 💡 Você também pode abrir e executar cada arquivo individualmente no SSMS via **File → Open → File...** seguido de **F5**.

---

## 🔬 Destaques Técnicos

### Índice de Penalidade por Faltas

Um dos KPIs centrais do módulo analítico é o **Índice de Penalidade**, que estratifica o risco de desperdício causado por alunos com histórico de no-show usando uma progressão exponencial:

$$\text{Índice} = 2^{\,N_{\text{faltas}}}$$

| Faltas | Índice | Classificação |
|:---:|:---:|---|
| 0 | 1 | ✅ Sem risco |
| 1 | 2 | 🟡 Baixo |
| 2 | 4 | 🟠 Médio |
| 3 | 8 | 🔴 Alto |
| 4+ | 16+ | 🚨 Crítico |

Esse índice alimenta a `View` de risco de desperdício, permitindo que a administração identifique e notifique os alunos com maior impacto operacional.

---

### Soft Delete com Trigger INSTEAD OF

Em vez de remover registros de alunos permanentemente, o que quebraria o histórico de agendamentos, a trigger intercepta o comando `DELETE` e executa uma inativação lógica:

```sql
CREATE TRIGGER trg_SoftDelete_Alunos
ON Alunos
INSTEAD OF DELETE
AS
BEGIN
    UPDATE Alunos
    SET ativo = 0, data_inativacao = GETDATE()
    WHERE id IN (SELECT id FROM deleted);
END;
```

Isso garante **integridade referencial** e **rastreabilidade** sem sacrificar a usabilidade.

---

### Índice Clustered por Data

Tabelas de agendamento são consultadas quase exclusivamente por intervalo de data. Recriar o índice `CLUSTERED` nessa coluna reduz drasticamente o custo de I/O:

```sql
-- Remove o clustered padrão (pela PK)
DROP INDEX PK_Agendamentos ON Agendamentos;

-- Recria como clustered por data de agendamento
CREATE CLUSTERED INDEX IX_Agendamentos_Data
ON Agendamentos (data_agendamento ASC);
```

---

## 🗺️ Modelo Relacional

> O diagrama completo está disponível em `docs/diagrama-relacional.png`.

Entidades principais e seus relacionamentos:

```
Alunos ──────────< Agendamentos >────────── Refeicoes
                        │                        │
                        │                        │
                   Presencas              Cardapio_Itens
                                               │
                                           Pratos
                        │
                   Avaliacoes
```

---

## 👤 Autor

**Lorenzo Avila**
[GitHub @Lorenzo-Avila](https://github.com/Lorenzo-Avila)
