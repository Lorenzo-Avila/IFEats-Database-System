-- ======================
-- 1. STORED PROCEDURES
-- ======================

-- sp_RegistrarAgendamento
-- Realiza o agendamento de um reifeição para um aluno.
-- Parâmetros de entrada, Inserção e Lógica Condiconal.

CREATE OR ALTER PROCEDURE sp_RegistrarAgendamento
    @MatriculaAluno VARCHAR(20),
    @CardapioID INT
AS
BEGIN
    SET NOCOUNT ON; -- Evita que a contagem de linhas. (Deixa mais clean, sem a mensagem de "(X) linha(s) afetadas")

    DECLARE @AlunoID INT;
    SELECT @AlunoID = AlunoID FROM Alunos WHERE Matricula = @MatriculaAluno;

    -- Lógica Condicional (v)
    IF @AlunoID IS NULL
    BEGIN
        RAISERROR('Erro: Aluno com a matrícula %s não encontrado.', 16, 1, @MatriculaAluno);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Cardapios WHERE CardapioID = @CardapioID)
    BEGIN
        RAISERROR('Erro: Cardápio com o ID %d não existe.', 16, 1, @CardapioID);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Agendamentos WHERE AlunoID = @AlunoID AND CardapioID = @CardapioID)
    BEGIN
        RAISERROR('Erro: O aluno já possui um agendamento para esta refeição.', 16, 1);
        RETURN;
    END

    -- Comando de Inserção (ii)
    INSERT INTO Agendamentos (AlunoID, CardapioID, DataHoraAgendamento, Status)
    VALUES (@AlunoID, @CardapioID, GETDATE(), 'Agendado');

    PRINT 'Agendamento registrado com sucesso para o aluno de matrícula ' + @MatriculaAluno + '.';
END;
GO

-- Execução: Aluno '2023115' agendando o almoço do dia 18/06/2025 (CardapioID 5)
EXEC sp_RegistrarAgendamento @MatriculaAluno = '2023107', @CardapioID = 5;
GO

------------------------------------------------------------------------------------------------------------------------------------------

-- sp_AtualizaStatusCheckin
-- Simula a passagem do aluno pela catraca, atuliza seu status.
-- Atualização.

CREATE OR ALTER PROCEDURE sp_AtualizarStatusCheckin
    @AgendamentoID INT
AS
BEGIN
    SET NOCOUNT ON; 

    IF NOT EXISTS (SELECT 1 FROM Agendamentos WHERE AgendamentoID = @AgendamentoID)
    BEGIN
        RAISERROR('Erro: Agendamento com ID %d não encontrado.', 16, 1, @AgendamentoID);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Agendamentos WHERE AgendamentoID = @AgendamentoID)
    BEGIN
        RAISERROR('Erro: O agendamento já foi realizado.', 16, 1, @AgendamentoID);
        RETURN;
    END
    -- Comando de Atualização (iii)
    UPDATE Agendamentos
    SET
        Status = 'Presente',
        DataHoraCheckin = GETDATE()
    WHERE AgendamentoID = @AgendamentoID;

    PRINT 'Check-in realizado com sucesso para o agendamento ID ' + CAST(@AgendamentoID AS VARCHAR) + '.'; 
END;
GO

-- Realizando o check-in de um agendamento AgendamentoID 21, ele mostrará mensagem e erro se já houver agendamento ou se o ID não existir.
EXEC sp_AtualizarStatusCheckin @AgendamentoID = 21;
GO

------------------------------------------------------------------------------------------------------------------------------------------

-- sp_CancelarAgendamento
-- Permite que um aluno cancele um agendamento existente.
-- Exclusão.

CREATE OR ALTER PROCEDURE sp_CancelarAgendamento
    @AgendamentoID INT
AS
BEGIN
    SET NOCOUNT ON; 

    DECLARE @CardapioData DATE;
    SELECT @CardapioData = C.DataCardapio
    FROM Agendamentos AG
    JOIN Cardapios C ON AG.CardapioID = C.CardapioID
    WHERE AG.AgendamentoID = @AgendamentoID;

    IF @CardapioData IS NULL
    BEGIN
        RAISERROR('Erro: Agendamento com ID %d não encontrado.', 16, 1, @AgendamentoID);
        RETURN;
    END

    -- Lógica condicional extra para evitar cancelamento de refeições passadas
    IF @CardapioData < CAST(GETDATE() AS DATE)
    BEGIN
        RAISERROR('Não é possível cancelar agendamentos de datas passadas.', 16, 1);
        RETURN;
    END

    -- Comando de Exclusão (iv)
    DELETE FROM Agendamentos
    WHERE AgendamentoID = @AgendamentoID;
    PRINT 'Agendamento ID ' + CAST(@AgendamentoID AS VARCHAR) + ' cancelado com sucesso.'; 
END;
GO

-- Cancelando o agendamento (supondo que o AgendamentoID seja 21)
EXEC sp_CancelarAgendamento @AgendamentoID = 21;
GO

------------------------------------------------------------------------------------------------------------------------------------------
-- sp_AdicionarNovoPratoCompleto
-- Cadastra um novo prato e suas informações nutricionais de uma só vez.
-- Parâmetros de entrada, Inserção e Lógica condicional.

CREATE OR ALTER PROCEDURE 
sp_AdicionarNovoPratoCompleto
    @NomePrato VARCHAR(150),
    @TipoPrato VARCHAR(50),
    @PorcaoGramas DECIMAL(7, 2),
    @Calorias DECIMAL(7, 2),
    @Proteinas DECIMAL(7, 2),
    @Carboidratos DECIMAL(7, 2),
    @Gorduras DECIMAL(7, 2),
    @Fibras DECIMAL(7, 2),
    @Sodio_mg DECIMAL(7, 2)
AS
BEGIN
    SET NOCOUNT ON;

    -- Lógica Condicional (v)
    IF EXISTS (SELECT 1 FROM Pratos WHERE NomePrato = @NomePrato)
    BEGIN
        RAISERROR('Erro: O prato "%s" já está cadastrado.', 16, 1, @NomePrato);
        RETURN;
    END

    DECLARE @NovoPratoID INT;

    -- Comando de Inserção (ii)
    INSERT INTO Pratos (NomePrato, TipoPrato) VALUES (@NomePrato, @TipoPrato);

    -- Captura o ID do prato recém-criado
    SET @NovoPratoID = SCOPE_IDENTITY();

    INSERT INTO InformacoesNutricionais (PratoID, PorcaoGramas, Calorias, Proteinas, Carboidratos, Gorduras, Fibras, Sodio_mg)
    VALUES (@NovoPratoID, @PorcaoGramas, @Calorias, @Proteinas, @Carboidratos, @Gorduras, @Fibras, @Sodio_mg);

    PRINT 'Prato "' + @NomePrato + '" e suas informações nutricionais foram adicionados com sucesso.';
END;
GO

-- Adicionando um novo prato completo ao sistema
EXEC sp_AdicionarNovoPratoCompleto
    @NomePrato = 'Salada Caesar',
    @TipoPrato = 'Salada',
    @PorcaoGramas = 150.00,
    @Calorias = 180.00,
    @Proteinas = 15.00,
    @Carboidratos = 5.00,
    @Gorduras = 10.00,
    @Fibras = 3.00,
    @Sodio_mg = 300.00;
GO

------------------------------------------------------------------------------------------------------------------------------------------

-- sp_ConsultarCardapioDoDia
-- Retorna o cardápio completo de um dia e tipo de refeição específicos.
-- procedure de consulta complexa.

CREATE OR ALTER PROCEDURE sp_ConsultarCardapioDoDia
    @DataConsulta DATE,
    @TipoRefeicao VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        P.NomePrato AS 'Prato',
        P.TipoPrato AS 'Tipo',
        INut.Calorias AS 'Kcal',
        INut.Proteinas AS 'Proteínas (g)',
        INut.Carboidratos AS 'Carboidratos (g)',
        INut.Gorduras AS 'Gorduras (g)'
    FROM Cardapios AS C
    JOIN ItensCardapio AS IC ON C.CardapioID = IC.CardapioID
    JOIN Pratos AS P ON IC.PratoID = P.PratoID
    LEFT JOIN InformacoesNutricionais AS INut ON P.PratoID = INut.PratoID
    WHERE C.DataCardapio = @DataConsulta AND C.TipoRefeicao = @TipoRefeicao
    ORDER BY P.TipoPrato, P.NomePrato;
END;
GO

-- Consultando o que tem para o almoço do dia 17/06/2025
EXEC sp_ConsultarCardapioDoDia @DataConsulta = '2025-06-17', @TipoRefeicao = 'Almoço';
GO

-- ======================
-- 2. TRIGGERS
-- ======================

-- trg_AposInserirAvaliacao
-- Exibe uma mensagem e o novo registro inserido na tabela Avaliacoes

CREATE OR ALTER TRIGGER trg_AposInserirAvaliacao
ON Avaliacoes
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'TRIGGER: Nova avaliação registrada com sucesso!';

    -- Mostra o registro que acabou de ser inserido, que está na 'inserted'.
    SELECT
        i.AvaliacaoID,
        i.AgendamentoID,
        i.Nota,
        i.Comentario,
        i.DataAvaliacao,
        A.NomeCompleto AS Aluno
    FROM inserted i
    JOIN Agendamentos AG ON i.AgendamentoID = AG.AgendamentoID
    JOIN Alunos A ON AG.AlunoID = A.AlunoID;
END;
GO

-- Tive que fazer um teste robusto com criação de cenário pra fazer um insert pq essa porcaria n dava certo nunca tlc.
    DECLARE @NovoAgendamentoID INT;

-- Criando um novo agendamento com status 'Presente' para garantir que exista um registro para realizar o teste.
INSERT INTO Agendamentos (AlunoID, CardapioID, DataHoraAgendamento, DataHoraCheckin, Status)
    VALUES (10, 10, GETDATE(), GETDATE(), 'Presente');
    SET @NovoAgendamentoID = SCOPE_IDENTITY(); -- Pega o ID do agendamento que acabamos de criar.
    PRINT 'Cenário de teste criado: Agendamento ' + CAST(@NovoAgendamentoID AS VARCHAR) + ' com status Presente.';

-- Insere a avaliação para o novo agendamento, disparando assim FINALMENTE a trigger.
INSERT INTO Avaliacoes (AgendamentoID, Nota, Comentario, DataAvaliacao)
    VALUES (@NovoAgendamentoID, 5, 'Teste de trigger com cenário recém-criado!', GETDATE());
GO

------------------------------------------------------------------------------------------------------------------------------------------

-- trg_LogAlteracaoEmailAluno
-- Registra em uma tabela de log qualquer alteração no e-mail de um aluno.

CREATE OR ALTER TRIGGER trg_LogAlteracaoEmailAluno
ON Alunos
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Verifica se a coluna 'Email' foi de fato atualizada.
    IF UPDATE(Email)
    BEGIN
        INSERT INTO LogAlteracoes (TabelaAfetada, RegistroID, ColunaAfetada, ValorAntigo, ValorNovo, UsuarioDaAcao, DataDaAcao)
        SELECT
            'Alunos',
            i.AlunoID,
            'Email',
            d.Email, -- Valor antigo da 'deleted'
            i.Email, -- Valor novo da 'inserted'
            SUSER_SNAME(), -- Captura o usuário do sistema que fez a ação
            GETDATE()
        FROM inserted i
        JOIN deleted d ON i.AlunoID = d.AlunoID;

        PRINT 'TRIGGER: Alteração de e-mail registrada no log.';
    END
END;
GO

-- Atualizando o e-mail de um aluno.
UPDATE Alunos SET Email = 'novo.email.teste@email.com' WHERE AlunoID = 15;
-- Verificando o log:
SELECT * FROM LogAlteracoes WHERE RegistroID = 15;
-- Revertendo a alteração para não sujar os dados
UPDATE Alunos SET Email = 'quintino.ramos@email.com' WHERE AlunoID = 15;
GO

------------------------------------------------------------------------------------------------------------------------------------------
-- trg_InativarAluno
-- ao tentar apagar o registro de um aluno apenas marca ele como inativo.

CREATE OR ALTER TRIGGER trg_InativarAluno
ON Alunos
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AlunoIDParaInativar INT;
    SELECT @AlunoIDParaInativar = AlunoID FROM deleted; -- Pega o ID do aluno da 'deleted'

    -- Mensagem em tela
    PRINT 'TRIGGER: Exclusão não permitida! O registro será inativado.';

    -- Modifica o registro para o status 'I' (Inativo)
    UPDATE Alunos
    SET Status = 'I'
    WHERE AlunoID = @AlunoIDParaInativar;
END;
GO

-- Tentando deletar um aluno.
DELETE FROM Alunos WHERE AlunoID = 14;
-- Verificando o status do aluno:
SELECT AlunoID, NomeCompleto, Status FROM Alunos WHERE AlunoID = 14;
-- Revertendo a alteração para não sujar os dados
UPDATE Alunos SET Status = 'A' WHERE AlunoID = 14;
GO

