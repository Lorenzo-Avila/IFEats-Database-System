-- =============================================================================
-- ÍNDICES
-- =============================================================================


-- Índice 1: CLUSTERED
-- i. Um índice clusterizado (CLUSTERED);
--
-- JUSTIFICATIVA:
-- Por padrão, sua chave primária da tabela de avaliações é (`AvaliacaoID`) o que já cria um índice clusterizado. No entanto,
-- para otimizar consultas por período, faz mais sentido que os dados estejam fisicamente
-- ordenados por `DataAvaliacao`. Ao criar o índice clusterizado nesta coluna, é garantido
-- que as avaliações sejam armazenadas em ordem cronológica, o que acelera
-- buscas por intervalo de datas.

-- 1: Remover a Chave Primária existente da tabela Avaliacoes.
-- Como esta tabela não é referenciada por outras é tranquilo
DECLARE @pk_name_avaliacoes NVARCHAR(200)
SELECT @pk_name_avaliacoes = name FROM sys.key_constraints WHERE type = 'PK' AND parent_object_id = OBJECT_ID('Avaliacoes')
IF @pk_name_avaliacoes IS NOT NULL
BEGIN
    EXEC('ALTER TABLE Avaliacoes DROP CONSTRAINT ' + @pk_name_avaliacoes)
    PRINT 'Chave Primária original da tabela Avaliacoes removida.';
END
GO

-- 2: Criar o novo Índice Clusterizado na coluna DataAvaliacao.
CREATE CLUSTERED INDEX idx_cl_Avaliacoes_DataAvaliacao ON Avaliacoes(DataAvaliacao);
PRINT 'Índice CLUSTERED idx_cl_Avaliacoes_DataAvaliacao criado com sucesso.';
GO

-- 3: Recriar a Chave Primária em AvaliacaoID como NONCLUSTERED.
ALTER TABLE Avaliacoes
ADD CONSTRAINT PK_Avaliacoes_AvaliacaoID PRIMARY KEY NONCLUSTERED (AvaliacaoID);
PRINT 'Chave Primária recriada como NONCLUSTERED em Avaliacoes(AvaliacaoID).';
GO

-- Teste
PRINT 'Executando consulta de intervalo de datas na tabela Avaliacoes...';
SELECT *
FROM Avaliacoes
WHERE DataAvaliacao BETWEEN '2025-06-16T00:00:00' AND '2025-06-16T23:59:59';
GO

------------------------------------------------------------------------------------------------------------------------------------------
-- Índice 2: NONCLUSTERED (Simples)
-- JUSTIFICATIVA:
-- É uma necessidade comum do sistema permitir a busca de um aluno pelo seu nome completo.
-- Sem um índice, uma consulta como `WHERE NomeCompleto = 'Ana Clara Borges'` forçaria o
-- SQL Server a ler a tabela `Alunos` inteira o que é muito lento
-- em tabelas grandes. Este índice cria uma estrutura de dados separada, ordenada pelo nome,
-- que aponta diretamente para o registro do aluno, otimizando assim o proceso.

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_nc_Alunos_NomeCompleto' AND object_id = OBJECT_ID('Alunos'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_nc_Alunos_NomeCompleto ON Alunos(NomeCompleto);
    PRINT 'Índice NONCLUSTERED idx_nc_Alunos_NomeCompleto criado com sucesso.';
END
GO

-- Testando 
SELECT * FROM Alunos WHERE NomeCompleto = 'Carla Andrade Lima';
GO

------------------------------------------------------------------------------------------------------------------------------------------
-- Índice 3: NONCLUSTERED (Composto)

-- JUSTIFICATIVA:
-- Uma das consultas mais frequentes seria para verificar os agendamentos de um aluno específico 
-- (`WHERE AlunoID = ?`) 
-- ou para validar se um aluno já agendou uma refeição específica 
-- (`WHERE AlunoID = ? AND CardapioID = ?`).
-- Um índice composto em `(AlunoID, CardapioID)` otimiza as buscas,
-- permitindo que o banco encontre os registros relevantes de forma direta, sem precisar
-- varrer a tabela inteira. A ordem (AlunoID, CardapioID) é a mais lógica, já que a busca
-- primária é geralmente por aluno.

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_nc_Agendamentos_AlunoCardapio' AND object_id = OBJECT_ID('Agendamentos'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_nc_Agendamentos_AlunoCardapio ON Agendamentos(AlunoID, CardapioID);
    PRINT 'Índice NONCLUSTERED Composto idx_nc_Agendamentos_AlunoCardapio criado com sucesso.';
END
GO

-- Testando
PRINT 'Executando consulta por AlunoID e CardapioID...';
SELECT * FROM Agendamentos WHERE AlunoID = 3 AND CardapioID = 1;
GO

------------------------------------------------------------------------------------------------------------------------------------------
-- Índice 4: NONCLUSTERED (Composto)
-- JUSTIFICATIVA:
-- A consulta mais fundamental do sistema é "o que tem para o almoço/jantar hoje?".
-- Essa operação busca na tabela `Cardapios` filtrando por `DataCardapio` e `TipoRefeicao`.
-- Este índice garante que a busca pelo cardápio do dia seja a mais rápida possível.

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_nc_Cardapios_DataTipo' AND object_id = OBJECT_ID('Cardapios'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_nc_Cardapios_DataTipo ON Cardapios(DataCardapio, TipoRefeicao);
    PRINT 'Índice NONCLUSTERED Composto idx_nc_Cardapios_DataTipo criado com sucesso.';
END
GO

-- Testando 
PRINT 'Executando consulta por Data e Tipo de Refeição...';
SELECT * FROM Cardapios WHERE DataCardapio = '2025-06-18' AND TipoRefeicao = 'Almoço';
GO