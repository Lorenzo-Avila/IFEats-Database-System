# 🍽️ IFEats - Ecossistema de Gestão de Refeitório (SQL Server)

O **IFEats** é um sistema de informação focado na gestão de refeitórios institucionais, projetado para otimizar a comunicação entre a administração e os estudantes. O projeto aborda desafios reais como o desperdício de alimentos, a gestão de demanda e a análise da satisfação dos usuários através de uma arquitetura de banco de dados robusta e automatizada.
## 🎯 Diferenciais do Projeto

O IFEats simula um ambiente de produção real, focando em quatro pilares fundamentais:

* **Modelagem Orientada ao Negócio:** Estrutura de dados normalizada que integra cadastros de alunos, cardápios semanais e tabelas nutricionais.
* **Business Intelligence (BI):** Camada analítica com `Views` prontas para consumo em ferramentas como Power BI, incluindo métricas de popularidade de pratos e taxas de no-show.
* **Automação de Backend:** Lógica de agendamento e check-in processada diretamente no servidor via `Stored Procedures` com controle transacional.
* **Segurança e Auditoria:** Rastreamento de alterações críticas e proteção contra deleção acidental através de logs automáticos e triggers de inativação.

## 🛠️ Tecnologias e Conceitos Aplicados

* **SGBD:** Microsoft SQL Server.
* **Linguagem:** T-SQL (Transact-SQL).
* **Destaques Técnicos:**
    * **Joins Avançados & Subqueries:** Para extração de KPIs complexos.
    * **Stored Procedures:** Com tratamento de erros e lógica condicional.
    * **Triggers:** `AFTER` para logs de auditoria e `INSTEAD OF` para implementação de *Soft Delete*.
    * **Performance:** Reestruturação de índices `CLUSTERED` para otimizar buscas cronológicas.

## 📂 Organização do Repositório

```text
/
├── docs/
│   ├── cenario-proposto.pdf        # Regras de negócio e requisitos do sistema
│   └── diagrama-relacional.png     # Modelo Entidade-Relacionamento (DER)
├── scripts/
│   ├── 01_setup_e_populacao.sql    # DDL/DML com recriação limpa e dados de teste
│   ├── 02_analytics_e_bi.sql       # Views, UDFs e consultas de análise gerencial
│   ├── 03_automacao_e_regras.sql   # Stored Procedures, Triggers e Transações
│   └── 04_performance.sql          # Estratégia de indexação customizada
├── backup/
│   └── IFEats-FullBackup.bak       # Backup completo para restauração do ambiente
└── README.md
```

## 🔧 Como Restaurar o Banco de Dados

Para testar o projeto em seu ambiente local:

1.  Baixe o arquivo `IFEats-FullBackup.bak` localizado na pasta `/backup`.
2.  No SQL Server Management Studio (SSMS), utilize o comando abaixo (ajustando os caminhos de diretório):

```sql
USE master;
GO
RESTORE DATABASE IFEats 
FROM DISK = 'C:\SEU_CAMINHO\IFEats-FullBackup.bak'
WITH REPLACE;
GO
```

---

### Exemplo de KPI Implementado
Um dos destaques do módulo analítico é o cálculo do **Índice de Penalidade** para alunos com faltas recorrentes, utilizando uma função exponencial para estratificação de risco de desperdício:
$$Indice = 2^{Nº de Faltas}$$

