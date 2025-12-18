-- function 1

CREATE OR ALTER FUNCTION dbo.udf_getUtilizador
(
    @id_user INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        u.UserKey,
        u.Email,
        c.FirstName,
        c.LastName,
        c.DateFirstPurchase
    FROM stg.stg_User u
    INNER JOIN stg.stg_Customer c
        ON u.UserKey = c.CustomerKey
    WHERE u.UserKey = @id_user
);
GO

SELECT * 
FROM dbo.udf_getUtilizador(11000);


--function 2
/*
CREATE OR ALTER FUNCTION dbo.udf_getTotalVendasCliente
(
    @CustomerKey INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Total DECIMAL(18,2);

    SELECT 
        @Total = SUM(od.Quantity * od.UnitPrice)
    FROM stg.stg_Sale s
    INNER JOIN stg.stg_OrderDetail od
        ON s.SalesOrderNumber = od.SalesOrderNumber
       AND s.SalesOrderLineNumber = od.SalesOrderLineNumber
    WHERE s.CustomerKey = @CustomerKey;

    RETURN ISNULL(@Total, 0);
END;
GO

SELECT dbo.udf_getTotalVendasCliente(11000) AS TotalVendas;
*/

-- function 3
/*
CREATE OR ALTER FUNCTION dbo.udf_getTotalVendasAno
(
    @Ano INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Total DECIMAL(18,2);

    SELECT 
        @Total = SUM(od.Quantity * od.UnitPrice)
    FROM stg.stg_Sale s
    INNER JOIN stg.stg_OrderDetail od
        ON s.SalesOrderNumber = od.SalesOrderNumber
       AND s.SalesOrderLineNumber = od.SalesOrderLineNumber
    WHERE YEAR(s.OrderDate) = @Ano;

    RETURN ISNULL(@Total, 0);
END;
GO

SELECT dbo.udf_getTotalVendasAno(2013) AS TotalVendasAno;
*/

--function 4
/*
CREATE OR ALTER FUNCTION dbo.udf_getTotalVendasProduto
(
    @ProductKey INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Total DECIMAL(18,2);

    SELECT 
        @Total = SUM(od.Quantity * od.UnitPrice)
    FROM stg.stg_OrderDetail od
    WHERE od.ProductKey = @ProductKey;

    RETURN ISNULL(@Total, 0);
END;
GO
*/





