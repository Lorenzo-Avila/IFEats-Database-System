use IFEats;
--------------------------------------------------------------------------------
-- JOINS
--------------------------------------------------------------------------------
-- INNER JOIN: Listar o nome dos alunos que compareceram (fizeram check-in), a data e o tipo da refeição que consumiram.
SELECT
    A.NomeCompleto AS Aluno,
    C.DataCardapio AS 'Data da refeição',
    C.TipoRefeicao AS 'Tipo de refeição'
FROM Agendamentos AS AG
INNER JOIN Alunos AS A ON AG.AlunoID = A.AlunoID
INNER JOIN Cardapios AS C ON AG.CardapioID = C.CardapioID
WHERE AG.DataHoraCheckin IS NOT NULL; -- Garante que o aluno fez check-in

-- LEFT JOIN: Listar TODOS os alunos e contar quantos agendamentos cada um realizou.
SELECT
    A.NomeCompleto AS Aluno,
    COUNT(AG.AgendamentoID) AS 'Nº de Agendamentos'
FROM Alunos AS A
LEFT JOIN Agendamentos AS AG ON A.AlunoID = AG.AlunoID
GROUP BY A.NomeCompleto
ORDER BY 'Nº de Agendamentos' DESC;

-- RIGHT JOIN: Listar todos os cardápios para garantir que nenhum seja esquecido e mostrar os nomes dos alunos que agendaram.
-- É útil para ver refeições com baixa adesão.
SELECT
    C.DataCardapio as 'Data do cardápio',
    C.TipoRefeicao as 'Tipo de refeição',
    A.NomeCompleto AS 'Alunos Que Agendaram'
FROM Agendamentos AS AG
RIGHT JOIN Cardapios AS C ON AG.CardapioID = C.CardapioID
LEFT JOIN Alunos AS A ON AG.AlunoID = A.AlunoID -- LEFT JOIN aqui para não perder cardápios sem agendamento
ORDER BY C.DataCardapio, C.TipoRefeicao;

-- FULL OUTER JOIN: Listar todos os pratos e todas as informações nutricionais. 
-- Garante que mesmo um prato sem dados nutricionais ou um dado nutricional sem prato vão apareçam na lista.
SELECT
    P.NomePrato AS 'Prato',
    P.TipoPrato AS 'Prato',
    INut.PorcaoGramas AS 'Porção em gramas',
    INut.Calorias AS 'Kcal',
    INut.Proteinas AS 'Proteinas',
    INut.Carboidratos AS 'Carboidratos',
    INut.Gorduras AS 'Gorduras',
    INut.Fibras AS 'Fibras',
    INut.Sodio_mg AS 'Sódio'
FROM Pratos AS P
FULL OUTER JOIN InformacoesNutricionais AS INut ON P.PratoID = INut.PratoID;

--------------------------------------------------------------------------------
-- GROUP BY + HAVING
--------------------------------------------------------------------------------
-- COUNT + GROUP BY + HAVING: Listar os alunos que realizaram 2 ou mais agendamentos.
SELECT
    A.NomeCompleto as 'Nome',
    COUNT(AG.AgendamentoID) AS 'Nº de Agendamentos'
FROM Agendamentos AS AG
JOIN Alunos AS A ON AG.AlunoID = A.AlunoID
GROUP BY A.NomeCompleto
HAVING COUNT(AG.AgendamentoID) >= 2
ORDER BY 'Nº de Agendamentos' DESC;

-- AVG + GROUP BY + HAVING: Listar a nota média dos pratos que foram avaliados mais de uma vez, mostrando apenas os com média maior que 3.
-- o que eu me quebrei pra fazer esse aqui tlc
SELECT
    P.NomePrato as 'Prato',
    ROUND(AVG(CAST(AV.Nota AS FLOAT)), 2) AS 'Media de avaliações', 
    COUNT(AV.AvaliacaoID) AS 'Quantidade de avalições'
FROM Avaliacoes AS AV
JOIN Agendamentos AS AG ON AV.AgendamentoID = AG.AgendamentoID
JOIN ItensCardapio AS IC ON AG.CardapioID = IC.CardapioID
JOIN Pratos AS P ON IC.PratoID = P.PratoID
GROUP BY P.NomePrato
HAVING COUNT(AV.AvaliacaoID) > 1 AND AVG(CAST(AV.Nota AS FLOAT)) > 3
ORDER BY 'Media de avaliações' DESC;

-- SUM + GROUP BY + HAVING: Listar os cardápios cujo somatório de calorias de todos os pratos ultrapassa 1200 kcal.
SELECT
    C.DataCardapio as 'Data do cardápio',
    C.TipoRefeicao as 'Tipo de refeição',
    SUM(INut.Calorias) AS 'Nº de calorias'
FROM Cardapios AS C
JOIN ItensCardapio AS IC ON C.CardapioID = IC.CardapioID
JOIN InformacoesNutricionais AS INut ON IC.PratoID = INut.PratoID
GROUP BY C.DataCardapio, C.TipoRefeicao
HAVING SUM(INut.Calorias) > 1200
ORDER BY 'Nº de calorias' DESC;

--------------------------------------------------------------------------------
-- VIEWS 
--------------------------------------------------------------------------------
-- Criação de View: Criar uma visão para simplificar a consulta ao relatório diário de frequência.

CREATE VIEW vw_RelatorioDiarioFrequencia AS
SELECT
    C.DataCardapio as 'Data do cardápio',
    C.TipoRefeicao as 'Tipo de refeição',
    COUNT(AG.AgendamentoID) AS TotalCheckins,
    SUM(CASE WHEN AG.Status = 'Presente' THEN 1 ELSE 0 END) AS Presentes,
    SUM(CASE WHEN AG.Status = 'Ausente' THEN 1 ELSE 0 END) AS Ausentes,
    SUM(CASE WHEN AG.Status = 'Não Agendado' THEN 1 ELSE 0 END) AS NaoAgendados
FROM Cardapios AS C
LEFT JOIN Agendamentos AS AG ON C.CardapioID = AG.CardapioID
WHERE AG.Status IN ('Presente', 'Ausente', 'Não Agendado')
GROUP BY C.DataCardapio, C.TipoRefeicao;

-- Consulta usando a View 1:
SELECT * FROM vw_RelatorioDiarioFrequencia ORDER BY 'Data do cardápio';

-- Criação de View: Criar uma visão para mostrar um ranking de popularidade dos pratos.
CREATE VIEW vw_RankingDePratos AS
SELECT
    P.NomePrato as 'Prato',
    P.TipoPrato 'Tipo',
    COUNT(IC.PratoID) AS 'Nº de vezes servido',
    ROUND(AVG(CAST(AV.Nota AS FLOAT)),2) AS 'Media de avalições'
FROM Pratos AS P
LEFT JOIN ItensCardapio AS IC ON P.PratoID = IC.PratoID
LEFT JOIN Agendamentos AS AG ON IC.CardapioID = AG.CardapioID
LEFT JOIN Avaliacoes AS AV ON AG.AgendamentoID = AV.AgendamentoID
GROUP BY P.NomePrato, P.TipoPrato;

-- Consulta usando a View 2:
SELECT * FROM vw_RankingDePratos ORDER BY 'Media de avalições' DESC, 'Nº de vezes servido' DESC;

--------------------------------------------------------------------------------
-- SUBQUERIES
--------------------------------------------------------------------------------
-- Subquery com IN: Listar o nome de todos os alunos que já consumiram, por exemplo, 'Torta de limão'.
SELECT NomeCompleto as 'Alunos que já consumiram "Torta de Limão"'
FROM Alunos
WHERE AlunoID IN (
    SELECT AG.AlunoID
    FROM Agendamentos AS AG
    JOIN ItensCardapio AS IC ON AG.CardapioID = IC.CardapioID
    JOIN Pratos AS P ON IC.PratoID = P.PratoID
    WHERE P.NomePrato = 'Torta de limão' AND AG.Status = 'Presente'
);

-- Subquery no FROM: Calcular a média de avaliações feitas por dia.
SELECT AVG(TotalAvaliacoesPorDia) AS 'Média de avalições por dia'
FROM (
    SELECT CAST(DataAvaliacao AS DATE) AS Dia, COUNT(AvaliacaoID) AS TotalAvaliacoesPorDia
    FROM Avaliacoes
    GROUP BY CAST(DataAvaliacao AS DATE)
) AS TabelaAvaliacoesPorDia;

-- Subquery Correlacionada no SELECT: Listar todos os alunos e a nota da sua primeira avaliação feita no sistema.
SELECT
    A.NomeCompleto as 'Nome',
    (SELECT TOP 1 AV.Nota
     FROM Avaliacoes AV
     JOIN Agendamentos AG ON AV.AgendamentoID = AG.AgendamentoID
     WHERE AG.AlunoID = A.AlunoID
     ORDER BY AV.DataAvaliacao ASC) AS 'Nota dada na Primeira avaliação'
FROM Alunos AS A;

--------------------------------------------------------------------------------
-- FUNÇÕES UDF, DATA E HORA, MATEMÁTICAS E DE STRING
--------------------------------------------------------------------------------
-- Função Escalar: Função que recebe o ID de um cardápio e retorna o nome do prato principal servido.
CREATE FUNCTION fn_ObterPratoPrincipal (@CardapioID INT)
RETURNS VARCHAR(150)
AS
BEGIN
    DECLARE @NomePratoPrincipal VARCHAR(150);
    SELECT TOP 1 @NomePratoPrincipal = P.NomePrato
    FROM ItensCardapio IC
    JOIN Pratos P ON IC.PratoID = P.PratoID
    WHERE IC.CardapioID = @CardapioID AND P.TipoPrato = 'Principal';
    RETURN @NomePratoPrincipal;
END;
-- Usando a função escalar:
SELECT CardapioID as 'Id do cardápio', DataCardapio as 'Data do cardápio', dbo.fn_ObterPratoPrincipal(CardapioID) AS 'Prato Principal' FROM Cardapios;

-- Função Inline Table-Valued: Criar uma função que retorna a lista de pratos de um determinado tipo.
CREATE FUNCTION fn_ListarPratosPorTipo (@TipoPrato VARCHAR(50))
RETURNS TABLE
AS
RETURN (
    SELECT NomePrato, TipoPrato
    FROM Pratos
    WHERE TipoPrato = @TipoPrato
);
-- Usando a função table-valued:
SELECT * FROM dbo.fn_ListarPratosPorTipo('Sobremesa');

--------------------------------------------------------------------------------
-- FUNÇÕES DE DATA E HORA
--------------------------------------------------------------------------------
-- DATEDIFF: Calcular o tempo médio, em horas, entre o agendamento e o check-in dos alunos.
SELECT AVG(DATEDIFF(HOUR, DataHoraAgendamento, DataHoraCheckin)) AS 'Tempo médio em horas entre agendamento e check-in'
FROM Agendamentos
WHERE Status = 'Presente';

-- FORMAT / DATEPART: Contar quantos check-ins ocorreram em cada dia da semana.
SELECT
    FORMAT(DataHoraCheckin, 'dddd', 'pt-BR') AS 'Dia da semana',
    COUNT(AgendamentoID) AS 'Nº total de check-in'
FROM Agendamentos
WHERE DataHoraCheckin IS NOT NULL
GROUP BY FORMAT(DataHoraCheckin, 'dddd', 'pt-BR'), DATEPART(WEEKDAY, DataHoraCheckin)
ORDER BY DATEPART(WEEKDAY, DataHoraCheckin);

-- GETDATE: Listar os agendamentos de alunos que fizeram check-in em um dia específico.
-- Por exemplo 16/06/2025
SELECT AlunoID as 'Id do aluno', CardapioID 'Id do cardápio', DataHoraCheckin as 'Data do check-in', Status
FROM Agendamentos
WHERE CAST(DataHoraCheckin AS DATE) = '2025-06-16';

--------------------------------------------------------------------------------
-- FUNÇÕES MATEMÁTICAS
--------------------------------------------------------------------------------
-- ROUND / AVG: Calcular a nota média geral de todas as avaliações, arredondada para 1 casa decimal.
SELECT ROUND(AVG(CAST(Nota AS FLOAT)), 1) AS 'Média geral de todas as avaliações'
FROM Avaliacoes;

-- POWER: Calcular um 'Índice de Penalidade' para alunos com faltas, onde a penalidade aumenta exponencialmente.
-- Por exemplo se o aluno chegar a número X de faltas ele recebe uma punição (isso aqui faz muita falta no orbital)
SELECT
    A.NomeCompleto,
    COUNT(AG.AgendamentoID) AS 'Nº de faltas',
    POWER(2, COUNT(AG.AgendamentoID)) AS 'Indice de penalidade'
FROM Agendamentos AS AG
JOIN Alunos AS A ON AG.AlunoID = A.AlunoID
WHERE AG.Status = 'Ausente'
GROUP BY A.NomeCompleto
ORDER BY 'Indice de penalidade' DESC;

-- SQRT: Cálcular o Índice de Energia para os pratos, muito utilizado na nutrição para normalizar os valores para um gráfico, reduzindo a diferença visual entre pratos muito calóricos.
SELECT
    P.NomePrato as 'Prato',
    INut.Calorias as 'Calorias',
    ROUND(SQRT(INut.Calorias),2) AS 'Índice de Energia'
FROM InformacoesNutricionais AS INut
JOIN Pratos AS P ON INut.PratoID = P.PratoID
WHERE INut.Calorias > 0;

-- CEILING / FLOOR: Mostrar o total de calorias de cada prato principal, arredondado para cima e para baixo.
SELECT
    NomePrato,
    Calorias,
    FLOOR(Calorias) AS 'Calorias arredondadas para baixo',
    CEILING(Calorias) AS 'Calorias arredondadas para cima'
FROM InformacoesNutricionais
JOIN Pratos ON InformacoesNutricionais.PratoID = Pratos.PratoID
WHERE Pratos.TipoPrato = 'Principal';

--------------------------------------------------------------------------------
-- FUNÇÕES DE STRING
--------------------------------------------------------------------------------
-- UPPER / CONCAT: Exibir o nome completo dos alunos em maiúsculas, junto com seu e-mail.
SELECT UPPER(NomeCompleto) AS 'NOME DO ALUNO', CONCAT('CONTATO: ', Email) AS 'Email'
FROM Alunos;

-- SUBSTRING / CHARINDEX: Listar apenas o primeiro nome de cada aluno.
SELECT SUBSTRING(NomeCompleto, 1, CHARINDEX(' ', NomeCompleto) - 1) AS 'Primeiro nome'
FROM Alunos
WHERE CHARINDEX(' ', NomeCompleto) > 0;


-- LEN / REPLACE: Listar comentários de avaliação que contenham a palavra 'comida', substituindo-a por '[refeição]' e mostrando o tamanho original do comentário.

SELECT
    Comentario AS 'Comentario Original',
    LEN(CAST(Comentario AS VARCHAR(MAX))) AS 'Tamanho Original',
    REPLACE(CAST(Comentario AS VARCHAR(MAX)), 'comida', 'refeição') AS 'Comentario Modificado'
FROM Avaliacoes
WHERE Comentario LIKE '%comida%';