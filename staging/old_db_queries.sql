/*
Grupo 5 
202300133, Filipe Rodrigues Patricio 
202300532, José Vicente Camolas da Silva 

Queries para verificar a conformidade da migração efetuada
*/

  /*
   Base de dados antiga
   */


-- Contagem total de produtos
SELECT COUNT(*) AS TotalProducts
FROM dbo.Product;
GO

-- Contagem de vendas (cada SalesOrderNumber conta como 1 venda mesmo que tenha várias linhas)
SELECT COUNT(DISTINCT SalesOrderNumber) AS TotalSalesOrders
FROM dbo.SalesOrderHeader;
GO

-- Vendas por cliente incluindo impostos
--  - Número de vendas (COUNT DISTINCT SalesOrderNumber)
--  - Valor total das vendas calculado como SUM((Quantity * UnitPrice) + TaxAmt)
SELECT
    c.CustomerID,
    p.FirstName + ' ' + p.LastName AS CustomerName,
    COUNT(DISTINCT soh.SalesOrderNumber) AS NumberOfSales,
    SUM((sod.OrderQty * sod.UnitPrice) + ISNULL(soh.TaxAmt, 0)) AS TotalVendas
FROM
    dbo.Customer c
    INNER JOIN dbo.SalesOrderHeader soh ON soh.CustomerID = c.CustomerID
    INNER JOIN dbo.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
    INNER JOIN dbo.Person p ON p.BusinessEntityID = c.PersonID
GROUP BY
    c.CustomerID, p.FirstName, p.LastName
ORDER BY
    TotalVendas DESC;
GO

-- Vendas totais por ano (ano retirado de OrderDate)
-- Valor calculado como SUM((Quantity * UnitPrice) + TaxAmt)
SELECT
    YEAR(soh.OrderDate) AS Ano,
    COUNT(DISTINCT soh.SalesOrderNumber) AS NumberOfSales,
    SUM((sod.OrderQty * sod.UnitPrice) + ISNULL(soh.TaxAmt, 0)) AS TotalVendasAno
FROM
    dbo.SalesOrderHeader soh
    INNER JOIN dbo.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
GROUP BY
    YEAR(soh.OrderDate)
ORDER BY
    Ano;
GO

-- Vendas por produto por ano incluindo impostos
-- Valor calculado como SUM((Quantity * UnitPrice) + TaxAmt)
SELECT
    YEAR(soh.OrderDate) AS Ano,
    p.ProductID,
    p.Name as ModelName,
    COUNT(DISTINCT soh.SalesOrderNumber) AS NumberOfSales,
    SUM((sod.OrderQty * sod.UnitPrice) + ISNULL(soh.TaxAmt, 0)) AS TotalVendas
FROM
    dbo.SalesOrderHeader soh
    INNER JOIN dbo.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
    INNER JOIN dbo.Product p ON sod.ProductID = p.ProductID
GROUP BY
    YEAR(soh.OrderDate), p.ProductID, p.Name
ORDER BY
    Ano, p.ProductID;
GO

-- Vendas por estado/província incluindo impostos
-- Valor calculado como SUM((Quantity * UnitPrice) + TaxAmt)
SELECT
    ISNULL(sp.Name, 'UNKNOWN') AS Estado,
    COUNT(DISTINCT soh.SalesOrderNumber) AS NumberOfSales,
    SUM((sod.OrderQty * sod.UnitPrice) + ISNULL(soh.TaxAmt, 0)) AS TotalVendas
FROM
    dbo.Customer c
    INNER JOIN dbo.SalesOrderHeader soh ON soh.CustomerID = c.CustomerID
    INNER JOIN dbo.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
    INNER JOIN dbo.Address a ON a.AddressID = soh.BillToAddressID
    INNER JOIN dbo.StateProvince sp ON sp.StateProvinceID = a.StateProvinceID
GROUP BY
    sp.Name
ORDER BY
    TotalVendas DESC;
GO