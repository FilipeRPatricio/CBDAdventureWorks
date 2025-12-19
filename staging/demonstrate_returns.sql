/*
Grupo 5
202300133, Filipe Rodrigues Patricio
202300532, José Vicente Camolas da Silva
*/

USE AdventureWorksLegacy;
GO

-- 1. Preparar o cenário: Selecionar um item de venda para a demonstração
-- Vamos pegar um item de uma venda existente para usar nos exemplos.
-- Assumimos que a venda 'SO75123' com a linha 1 e produto 998 existe e tem uma quantidade de 1.
-- Se não, pode substituir por qualquer outra venda válida.

DECLARE @SalesOrderNumber NVARCHAR(20) = 'SO44368';
DECLARE @SalesOrderLineNumber INT = 1;
DECLARE @ProductKey INT = 314;
DECLARE @QtySold INT;

-- Limpar devoluções anteriores para este item para garantir um teste limpo
DELETE FROM stg.stg_Returns
WHERE SalesOrderNumber = @SalesOrderNumber AND SalesOrderLineNumber = @SalesOrderLineNumber;

-- Obter a quantidade vendida
SELECT @QtySold = Quantity
FROM stg.stg_OrderDetail
WHERE SalesOrderNumber = @SalesOrderNumber AND SalesOrderLineNumber = @SalesOrderLineNumber;

PRINT 'Cenário de Teste:';
PRINT 'Venda: ' + @SalesOrderNumber + ', Linha: ' + CAST(@SalesOrderLineNumber AS NVARCHAR(10));
PRINT 'Quantidade Vendida: ' + CAST(@QtySold AS NVARCHAR(10));
PRINT '----------------------------------------------------';
GO

-- 2. Demonstração de uma devolução bem-sucedida
-- Vamos devolver 1 item. Como a quantidade vendida é 1, isto deve funcionar.
PRINT 'Executando uma devolução válida de 1 item...';
BEGIN TRY
    EXEC stg.usp_ProcessReturn
        @SalesOrderNumber = 'SO75123',
        @SalesOrderLineNumber = 1,
        @QuantityToReturn = 1,
        @Reason = 'Produto com defeito';
END TRY
BEGIN CATCH
    PRINT 'Ocorreu um erro inesperado: ' + ERROR_MESSAGE();
END CATCH
PRINT '----------------------------------------------------';
GO

-- 3. Demonstração de uma tentativa de devolução que viola a regra de negócio
-- Agora, vamos tentar devolver mais 1 item. Como já devolvemos 1, o total (1+1) excederá a quantidade vendida (1).
-- O procedimento deve lançar um erro.
PRINT 'Executando uma devolução inválida (excede a quantidade vendida)...';
BEGIN TRY
    EXEC stg.usp_ProcessReturn
        @SalesOrderNumber = 'SO75123',
        @SalesOrderLineNumber = 1,
        @QuantityToReturn = 1,
        @Reason = 'Cliente mudou de ideias';
END TRY
BEGIN CATCH
    PRINT '-> Erro esperado capturado: ' + ERROR_MESSAGE();
END CATCH
PRINT '----------------------------------------------------';
GO

-- 4. Verificar o estado final da tabela de devoluções
-- Apenas a primeira devolução (a válida) deve estar registada na tabela.
PRINT 'Verificando o estado final da tabela stg.stg_Returns para o item:';
SELECT
    ReturnID,
    SalesOrderNumber,
    SalesOrderLineNumber,
    ReturnDate,
    Quantity,
    Reason
FROM stg.stg_Returns
WHERE SalesOrderNumber = 'SO75123' AND SalesOrderLineNumber = 1;
GO
