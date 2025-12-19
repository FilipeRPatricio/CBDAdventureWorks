/*
Grupo 5
202300133, Filipe Rodrigues Patricio
202300532, José Vicente Camolas da Silva
*/

USE AdventureWorksLegacy;
GO

-- Criação da tabela de Devoluções (se não existir)
-- Necessária para registar o histórico de devoluções e validar quantidades.
IF OBJECT_ID('stg.stg_Returns', 'U') IS NULL
BEGIN
    CREATE TABLE stg.stg_Returns (
        ReturnID INT IDENTITY(1,1) PRIMARY KEY,
        SalesOrderNumber NVARCHAR(20) NOT NULL,
        SalesOrderLineNumber INT NOT NULL,
        ReturnDate DATETIME DEFAULT GETDATE(),
        Quantity INT NOT NULL,
        Reason NVARCHAR(255),

        CONSTRAINT FK_Returns_OrderDetail FOREIGN KEY (SalesOrderNumber, SalesOrderLineNumber)
        REFERENCES stg.stg_OrderDetail(SalesOrderNumber, SalesOrderLineNumber)
    );
END;
GO

/*
Procedimento: stg.usp_ProcessReturn
Descrição: Processa uma devolução de um item de venda, garantindo consistência em ambiente concorrente.

Solução Transacional:
Utiliza o nível de isolamento SERIALIZABLE (Pessimistic Locking).

Justificativa:
O requisito pede para evitar inconsistências em devoluções concorrentes (ex: devolver mais itens do que os vendidos).
Para validar uma devolução, precisamos de ler a soma de todas as devoluções anteriores (SUM(Quantity)) e garantir que
(Soma Anterior + Nova Quantidade) <= Quantidade Vendida.

Num nível de isolamento inferior (como READ COMMITTED ou mesmo REPEATABLE READ), duas transações concorrentes poderiam
ler a mesma "Soma Anterior" simultaneamente, validar a condição com sucesso e ambas inserirem uma nova devolução,
resultando num total devolvido superior ao vendido (Anomalia de Phantom Read / Write Skew).

O nível SERIALIZABLE garante que, ao ler os registos de devoluções para um determinado item, o motor de base de dados
bloqueia o intervalo (Range Lock). Isto impede que qualquer outra transação insira uma nova devolução para esse mesmo
item até que a transação atual termine, garantindo assim a integridade da regra de negócio.
*/
CREATE OR ALTER PROCEDURE stg.usp_ProcessReturn
    @SalesOrderNumber NVARCHAR(20),
    @SalesOrderLineNumber INT,
    @QuantityToReturn INT,
    @Reason NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- Definir nível de isolamento SERIALIZABLE para prevenir Phantom Reads e garantir exclusividade na validação
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Verificar a quantidade original vendida
        -- (Nota: SERIALIZABLE também garante que este registo não é alterado/apagado durante a transação)
        DECLARE @QtySold INT;
        SELECT @QtySold = Quantity
        FROM stg.stg_OrderDetail
        WHERE SalesOrderNumber = @SalesOrderNumber
          AND SalesOrderLineNumber = @SalesOrderLineNumber;

        IF @QtySold IS NULL
        BEGIN
            THROW 50001, 'Item de venda não encontrado.', 1;
        END

        -- 2. Calcular a quantidade já devolvida
        -- O nível SERIALIZABLE coloca bloqueios que impedem outros INSERTS para este (SalesOrderNumber, SalesOrderLineNumber)
        DECLARE @QtyReturnedAlready INT;
        SELECT @QtyReturnedAlready = ISNULL(SUM(Quantity), 0)
        FROM stg.stg_Returns
        WHERE SalesOrderNumber = @SalesOrderNumber
          AND SalesOrderLineNumber = @SalesOrderLineNumber;

        -- 3. Validar se a nova devolução excede o limite
        IF (@QtyReturnedAlready + @QuantityToReturn) > @QtySold
        BEGIN
            DECLARE @Msg NVARCHAR(255) = FORMATMESSAGE('Erro: Devolução excede a quantidade vendida. Vendido: %d, Já Devolvido: %d, Tentativa: %d', @QtySold, @QtyReturnedAlready, @QuantityToReturn);
            THROW 50002, @Msg, 1;
        END

        -- 4. Registar a devolução
        INSERT INTO stg.stg_Returns (SalesOrderNumber, SalesOrderLineNumber, Quantity, Reason)
        VALUES (@SalesOrderNumber, @SalesOrderLineNumber, @QuantityToReturn, @Reason);

        COMMIT TRANSACTION;

        SELECT 'Devolução processada com sucesso.' AS Message, SCOPE_IDENTITY() AS ReturnID;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH
END;
GO
