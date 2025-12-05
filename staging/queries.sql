/*
Grupo 5 
202300133, Filipe Rodrigues Patricio 
202300532, José Vicente Camolas da Silva 

Queries para verificar a conformidade da migração efetuada
*/

  /*
   Base de dados nova
   */
-- Contagem total de produtos
SELECT COUNT(*) AS TotalProducts
FROM stg.stg_Product;
GO

-- Contagem de vendas (cada SalesOrderNumber conta como 1 venda mesmo que tenha várias linhas)
SELECT COUNT(DISTINCT SalesOrderNumber) AS TotalSalesOrders
FROM stg.stg_Sale;
GO

-- Vendas por cliente incluindo impostos
--  - Número de vendas (COUNT DISTINCT SalesOrderNumber)
--  - Valor total das vendas calculado como SUM((Quantity * UnitPrice) + TaxAmt)
SELECT
    c.CustomerKey,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    COUNT(DISTINCT s.SalesOrderNumber) AS NumberOfSales,
    SUM((od.Quantity * od.UnitPrice) + ISNULL(od.TaxAmt, 0)) AS TotalVendas
FROM
    stg.stg_Customer c
    INNER JOIN stg.stg_Sale s ON s.CustomerKey = c.CustomerKey
    INNER JOIN stg.stg_OrderDetail od
        ON od.SalesOrderNumber = s.SalesOrderNumber
        AND od.SalesOrderLineNumber = s.SalesOrderLineNumber
GROUP BY
    c.CustomerKey, c.FirstName, c.LastName
ORDER BY
    TotalVendas DESC;
GO

-- Vendas totais por ano (ano retirado de OrderDate)
-- Valor calculado como SUM((Quantity * UnitPrice) + TaxAmt)
SELECT
    YEAR(s.OrderDate) AS Ano,
    COUNT(DISTINCT s.SalesOrderNumber) AS NumberOfSales,
    SUM((od.Quantity * od.UnitPrice) + ISNULL(od.TaxAmt, 0)) AS TotalVendasAno
FROM
    stg.stg_Sale s
    INNER JOIN stg.stg_OrderDetail od
        ON od.SalesOrderNumber = s.SalesOrderNumber
        AND od.SalesOrderLineNumber = s.SalesOrderLineNumber
GROUP BY
    YEAR(s.OrderDate)
ORDER BY
    Ano;
GO

-- Vendas por produto por ano incluindo impostos
-- Valor calculado como SUM((Quantity * UnitPrice) + TaxAmt)
SELECT
    YEAR(s.OrderDate) AS Ano,
    p.ProductKey,
    p.ModelName,
    COUNT(DISTINCT s.SalesOrderNumber) AS NumberOfSales,
    SUM((od.Quantity * od.UnitPrice) + ISNULL(od.TaxAmt, 0)) AS TotalVendas
FROM
    stg.stg_Sale s
    INNER JOIN stg.stg_OrderDetail od
        ON od.SalesOrderNumber = s.SalesOrderNumber
        AND od.SalesOrderLineNumber = s.SalesOrderLineNumber
    INNER JOIN stg.stg_Product p
        ON od.ProductKey = p.ProductKey
GROUP BY
    YEAR(s.OrderDate), p.ProductKey, p.ModelName
ORDER BY
    Ano, p.ProductKey;
GO

-- Vendas por estado/província incluindo impostos
-- Valor calculado como SUM((Quantity * UnitPrice) + TaxAmt)
SELECT
    ISNULL(c.StateProvinceName, 'UNKNOWN') AS Estado,
    COUNT(DISTINCT s.SalesOrderNumber) AS NumberOfSales,
    SUM((od.Quantity * od.UnitPrice) + ISNULL(od.TaxAmt, 0)) AS TotalVendas
FROM
    stg.stg_Customer c
    INNER JOIN stg.stg_Sale s ON s.CustomerKey = c.CustomerKey
    INNER JOIN stg.stg_OrderDetail od
        ON od.SalesOrderNumber = s.SalesOrderNumber
        AND od.SalesOrderLineNumber = s.SalesOrderLineNumber
GROUP BY
    c.StateProvinceName
ORDER BY
    TotalVendas DESC;
GO