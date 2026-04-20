-- Garante que estamos no contexto do banco de dados master para poder apagar o IFEats se ele existir
USE master;
GO

-- Apaga o banco de dados se ele já existir, para garantir uma recriação limpa
IF DB_ID('IFEats') IS NOT NULL
BEGIN
    ALTER DATABASE IFEats SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE IFEats;
    PRINT 'Banco de dados IFEats anterior apagado com sucesso.';
END
GO

-- --------------------------------------------------------------------------------
-- CRIAÇÃO DO BANCO IFEats
-- --------------------------------------------------------------------------------
CREATE DATABASE IFEats;
GO

USE IFEats;
GO

PRINT 'Banco de dados IFEats criado e selecionado.';
GO

-- --------------------------------------------------------------------------------
-- CRIAÇÃO DAS TABELAS (DDL)
-- --------------------------------------------------------------------------------

-- 1. Tabela de Alunos
CREATE TABLE Alunos (
    AlunoID INT PRIMARY KEY IDENTITY(1,1),
    NomeCompleto VARCHAR(255) NOT NULL,
    Matricula VARCHAR(20) NOT NULL UNIQUE,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Status CHAR(1) NOT NULL DEFAULT 'A' -- 'A' para Ativo, 'I' para Inativo
);
PRINT 'Tabela Alunos criada.';

-- 2. Tabela de Pratos
CREATE TABLE Pratos (
    PratoID INT PRIMARY KEY IDENTITY(1,1),
    NomePrato VARCHAR(150) NOT NULL UNIQUE,
    TipoPrato VARCHAR(50)
);
PRINT 'Tabela Pratos criada.';

-- 3. Tabela de Cardápios
CREATE TABLE Cardapios (
    CardapioID INT PRIMARY KEY IDENTITY(1,1),
    DataCardapio DATE NOT NULL,
    TipoRefeicao VARCHAR(50) NOT NULL,
    CONSTRAINT UQ_CardapioDiaTipo UNIQUE (DataCardapio, TipoRefeicao)
);
PRINT 'Tabela Cardapios criada.';

-- 4. Tabela de InformacoesNutricionais
CREATE TABLE InformacoesNutricionais (
    NutricionalID INT PRIMARY KEY IDENTITY(1,1),
    PratoID INT NOT NULL UNIQUE,
    PorcaoGramas DECIMAL(7, 2) NOT NULL,
    Calorias DECIMAL(7, 2),
    Proteinas DECIMAL(7, 2),
    Carboidratos DECIMAL(7, 2),
    Gorduras DECIMAL(7, 2),
    Fibras DECIMAL(7, 2),
    Sodio_mg DECIMAL(7, 2),
    FOREIGN KEY (PratoID) REFERENCES Pratos(PratoID)
);
PRINT 'Tabela InformacoesNutricionais criada.';

-- 5. Tabela ItensCardapio
CREATE TABLE ItensCardapio (
    CardapioID INT NOT NULL,
    PratoID INT NOT NULL,
    PRIMARY KEY (CardapioID, PratoID),
    FOREIGN KEY (CardapioID) REFERENCES Cardapios(CardapioID),
    FOREIGN KEY (PratoID) REFERENCES Pratos(PratoID)
);
PRINT 'Tabela ItensCardapio criada.';

-- 6. Tabela de Agendamentos
CREATE TABLE Agendamentos (
    AgendamentoID INT PRIMARY KEY IDENTITY(1,1),
    AlunoID INT NOT NULL,
    CardapioID INT NOT NULL,
    DataHoraAgendamento DATETIME NOT NULL,
    DataHoraCheckin DATETIME,
    Status VARCHAR(20) NOT NULL,
    FOREIGN KEY (AlunoID) REFERENCES Alunos(AlunoID),
    FOREIGN KEY (CardapioID) REFERENCES Cardapios(CardapioID)
);
PRINT 'Tabela Agendamentos criada.';

-- 7. Tabela de Avaliações
CREATE TABLE Avaliacoes (
    AvaliacaoID INT PRIMARY KEY IDENTITY(1,1),
    AgendamentoID INT NOT NULL UNIQUE,
    Nota INT,
    Comentario VARCHAR(MAX), -- Alterado de TEXT para VARCHAR(MAX)
    DataAvaliacao DATETIME NOT NULL,
    FOREIGN KEY (AgendamentoID) REFERENCES Agendamentos(AgendamentoID)
);
PRINT 'Tabela Avaliacoes criada.';

-- 8. Tabela de Log
CREATE TABLE LogAlteracoes (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    TabelaAfetada VARCHAR(100),
    RegistroID INT,
    ColunaAfetada VARCHAR(100),
    ValorAntigo VARCHAR(MAX),
    ValorNovo VARCHAR(MAX),
    UsuarioDaAcao VARCHAR(100),
    DataDaAcao DATETIME
);
PRINT 'Tabela LogAlteracoes criada.';
GO

-- --------------------------------------------------------------------------------
-- INSERÇÃO DE DADOS (DML)
-- --------------------------------------------------------------------------------

-- 1. Inserindo dados na Tabela de Alunos
INSERT INTO Alunos (NomeCompleto, Matricula, Email) VALUES
('Ana Clara Borges', '2023101', 'ana.borges@email.com'), ('Bruno Carvalho Dias', '2023102', 'bruno.dias@email.com'),
('Carla Andrade Lima', '2023103', 'carla.lima@email.com'), ('Daniel Faria Costa', '2023104', 'daniel.costa@email.com'),
('Fernanda Souza Melo', '2023105', 'fernanda.melo@email.com'), ('Gabriel Oliveira Santos', '2023106', 'gabriel.santos@email.com'),
('Helena Rocha Alves', '2023107', 'helena.alves@email.com'), ('Igor Martins Ferreira', '2023108', 'igor.ferreira@email.com'),
('Julia Nogueira Barros', '2023109', 'julia.barros@email.com'), ('Lucas Pereira Ribeiro', '2023110', 'lucas.ribeiro@email.com'),
('Mariana Cunha Azevedo', '2023111', 'mariana.azevedo@email.com'), ('Nelson Gomes Pinto', '2023112', 'nelson.pinto@email.com'),
('Olivia Dias Cardoso', '2023113', 'olivia.cardoso@email.com'), ('Pedro Viana Monteiro', '2023114', 'pedro.monteiro@email.com'),
('Quintino Sales Ramos', '2023115', 'quintino.ramos@email.com');
PRINT '15 alunos inseridos.';

-- 2. Inserindo dados na Tabela de Pratos
INSERT INTO Pratos (NomePrato, TipoPrato) VALUES
('Arroz Branco', 'Guarnição'), ('Feijão Carioca', 'Guarnição'), ('Estrogonofe de Frango', 'Principal'),
('Bife Acebolado', 'Principal'), ('Salada de Alface e Tomate', 'Salada'), ('Purê de Batata', 'Guarnição'),
('Mousse de Maracujá', 'Sobremesa'), ('Pudim de Leite', 'Sobremesa'), ('Frango Grelhado', 'Principal'),
('Lasanha à Bolonhesa', 'Principal'), ('Arroz Integral', 'Guarnição'), ('Salada de Maionese', 'Guarnição'),
('Torta de Limão', 'Sobremesa'), ('Suco de Laranja', 'Bebida'), ('Feijoada Completa', 'Principal'),
('Peixe Frito', 'Principal');
PRINT '16 pratos inseridos.';

-- 3. Inserindo dados na Tabela de Cardápios (incluindo cardápios futuros)
INSERT INTO Cardapios (DataCardapio, TipoRefeicao) VALUES
('20250616', 'Almoço'), ('20250616', 'Jantar'), ('20250617', 'Almoço'), ('20250617', 'Jantar'),
('20250618', 'Almoço'), ('20250618', 'Jantar'), ('20250619', 'Almoço'), ('20250619', 'Jantar'),
('20250620', 'Almoço'), ('20250620', 'Jantar'), ('20250621', 'Almoço'), ('20250622', 'Almoço'),
('20250623', 'Almoço'), ('20250623', 'Jantar'), ('20250624', 'Almoço'),
-- Cardápios futuros para testes de cancelamento (formato YYYYMMDD)
(DATEADD(year, 1, '20250719'), 'Almoço'), (DATEADD(year, 1, '20250719'), 'Jantar'), (DATEADD(year, 1, '20250720'), 'Almoço');
PRINT '18 cardápios inseridos (incluindo 3 futuros).';

-- 4. Inserindo dados na Tabela de InformacoesNutricionais
INSERT INTO InformacoesNutricionais (PratoID, PorcaoGramas, Calorias, Proteinas, Carboidratos, Gorduras, Fibras, Sodio_mg) VALUES
(1, 100, 128, 2.5, 28, 0.3, 0.2, 1), (2, 100, 76, 5, 14, 0.5, 4.8, 2), (3, 150, 350, 30, 8, 22, 1, 500),
(4, 120, 280, 25, 2, 19, 0.5, 350), (5, 80, 15, 1, 3, 0.2, 1.5, 5), (6, 120, 110, 2, 18, 3.5, 2, 250),
(7, 90, 220, 4, 30, 9, 1, 80), (8, 100, 150, 6, 25, 3, 0, 110), (9, 150, 210, 35, 0, 7, 0, 150),
(10, 250, 480, 25, 45, 22, 5, 800), (11, 100, 112, 2.6, 24, 0.9, 2.7, 5), (12, 150, 260, 4, 20, 18, 2.5, 300),
(13, 110, 320, 5, 45, 14, 1.2, 150), (14, 300, 140, 2, 33, 0.3, 0.6, 10), (15, 300, 550, 30, 50, 25, 15, 1200),
(16, 150, 340, 20, 15, 22, 1, 400);
PRINT '16 registros de informações nutricionais inseridos.';

-- 5. Inserindo dados na Tabela ItensCardapio
INSERT INTO ItensCardapio (CardapioID, PratoID) VALUES
(1,1),(1,2),(1,3),(1,5),(1,7),(1,14), (2,1),(2,2),(2,4),(2,5),(2,8),(2,14), (3,11),(3,2),(3,9),(3,12),(3,13),(3,14),
(4,1),(4,2),(4,10),(4,5),(4,7),(4,14), (5,1),(5,2),(5,15),(5,5),(5,8),(5,14), (6,11),(6,2),(6,16),(6,6),(6,13),(6,14),
(7,1),(7,2),(7,3),(7,12),(7,8),(7,14), (8,1),(8,2),(8,4),(8,5),(8,7),(8,14), (9,11),(9,2),(9,9),(9,6),(9,13),(9,14),
(10,1),(10,2),(10,10),(10,12),(10,8),(10,14), (11,1),(11,2),(11,15),(11,5),(11,7),(11,14), (12,11),(12,2),(12,16),(12,5),(12,13),(12,14),
(13,1),(13,2),(13,3),(13,6),(13,8),(13,14), (14,11),(14,2),(14,4),(14,12),(14,7),(14,14), (15,1),(15,2),(15,9),(15,5),(15,13),(15,14);
PRINT 'Itens de cardápio inseridos.';

-- 6. Inserindo dados na Tabela de Agendamentos (incluindo agendamentos futuros)
INSERT INTO Agendamentos (AlunoID, CardapioID, DataHoraAgendamento, DataHoraCheckin, Status) VALUES
(1, 1, '2025-06-15T10:00:00', '2025-06-16T12:05:00', 'Presente'), (2, 1, '2025-06-15T11:30:00', '2025-06-16T12:10:00', 'Presente'),
(3, 1, '2025-06-15T14:00:00', NULL, 'Ausente'), (4, 1, GETDATE(), '2025-06-16T12:30:00', 'Não Agendado'),
(5, 2, '2025-06-16T09:00:00', '2025-06-16T19:00:00', 'Presente'), (6, 2, '2025-06-16T18:00:00', '2025-06-16T19:05:00', 'Presente'),
(7, 2, '2025-06-16T18:10:00', NULL, 'Ausente'), (8, 3, '2025-06-17T08:00:00', '2025-06-17T12:00:00', 'Presente'),
(9, 3, '2025-06-17T08:30:00', '2025-06-17T12:15:00', 'Presente'), (10, 3, '2025-06-17T09:00:00', '2025-06-17T12:20:00', 'Presente'),
(11, 4, GETDATE(), '2025-06-17T19:30:00', 'Não Agendado'), (12, 5, '2025-06-17T20:00:00', '2025-06-18T12:10:00', 'Presente'),
(13, 5, '2025-06-17T21:00:00', NULL, 'Ausente'), (14, 5, '2025-06-18T07:00:00', '2025-06-18T12:40:00', 'Presente'),
(15, 5, '2025-06-18T08:00:00', '2025-06-18T12:50:00', 'Presente'), (1, 13, '2025-06-22T10:00:00', NULL, 'Agendado'),
(2, 13, '2025-06-22T11:00:00', NULL, 'Agendado'), (3, 14, '2025-06-23T09:00:00', NULL, 'Agendado'),
(4, 14, '2025-06-23T09:30:00', NULL, 'Agendado'), (5, 15, GETDATE(), '2025-06-24T12:00:00', 'Presente'),
-- Agendamentos futuros
(1, 16, GETDATE(), NULL, 'Agendado'), (2, 17, GETDATE(), NULL, 'Agendado'), (3, 18, GETDATE(), NULL, 'Agendado');
PRINT '23 agendamentos inseridos (incluindo 3 futuros).';

-- 7. Inserindo dados na Tabela de Avaliações
INSERT INTO Avaliacoes (AgendamentoID, Nota, Comentario, DataAvaliacao) VALUES
(1, 5, 'Estrogonofe estava delicioso!', '2025-06-16T13:00:00'), (2, 4, 'Comida boa, mas a fila estava grande.', '2025-06-16T13:15:00'),
(4, 4, 'Mesmo sem agendar, o atendimento foi rápido. Bom trabalho!', '2025-06-16T13:30:00'), (5, 5, 'Jantar excelente, tudo perfeito.', '2025-06-16T19:40:00'),
(6, 3, 'O bife estava um pouco frio.', '2025-06-16T20:00:00'), (8, 5, 'Frango grelhado no ponto certo! E a maionese estava ótima.', '2025-06-17T12:30:00'),
(9, 4, 'Gostei muito, mas poderia ter mais uma opção de sobremesa.', '2025-06-17T12:45:00'), (10, 5, 'Tudo ótimo, como sempre.', '2025-06-17T12:55:00'),
(11, 3, 'A lasanha estava um pouco salgada para o meu gosto.', '2025-06-17T20:10:00'), (12, 5, 'Feijoada espetacular! Melhor do semestre!', '2025-06-18T13:00:00'),
(14, 4, 'Gostei muito da feijoada, mas o arroz podia estar mais soltinho.', '2025-06-18T13:10:00'), (15, 4, 'A feijoada estava boa, mas senti falta de uma farofa.', '2025-06-18T13:20:00'),
(20, 5, 'Ótimo atendimento e comida saborosa. Valeu a pena!', '2025-06-24T13:00:00');
PRINT '13 avaliações inseridas.';
GO

PRINT '-------------------------------------------------';
PRINT 'BANCO DE DADOS IFEats CRIADO E POPULADO COM SUCESSO!';
PRINT '-------------------------------------------------';
GO
