
use AdventureWorksLegacy
GO


-- Número total de produtos válidos (com preço >= 1)
SELECT COUNT(*) AS total_valid_products
FROM AdventureWorksLegacy.dbo.Products
WHERE TRY_CAST(ListPrice AS DECIMAL(18,2)) >= 1
  AND TRY_CAST(DealerPrice AS DECIMAL(18,2)) >= 1;

-- Top 5 produtos mais caros
SELECT TOP 5 ProductKey, ModelName, ListPrice
FROM AdventureWorksLegacy.dbo.Products
ORDER BY TRY_CAST(ListPrice AS DECIMAL(18,2)) DESC;

-- Número de produtos por categoria
SELECT ps.EnglishProductSubcategoryName, COUNT(p.ProductKey) AS total_products
FROM AdventureWorksLegacy.dbo.Products p
JOIN AdventureWorksLegacy.dbo.ProductSubCategory ps 
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
GROUP BY ps.EnglishProductSubcategoryName
ORDER BY total_products DESC;


-- Consultas de comparação entre Legacy e Normalizada

--           produtos
--legacy
SELECT COUNT(*) AS TotalProducts
FROM AdventureWorksLegacy.dbo.Products;

--normalizada
SELECT COUNT(*) AS TotalProducts
FROM AdventureWorksLegacy.stg.stg_Product;


--    Top 3 total de Vendas por Cliente
--legacy
SELECT
    top 3
    S.CustomerKey,
    SUM(S.UnitPrice) AS TotalSalesValue
FROM AdventureWorksLegacy.dbo.Sales AS S
GROUP BY S.CustomerKey
ORDER BY TotalSalesValue DESC;


--normalizada
SELECT
    top 3
    SA.CustomerKey,
    SUM(OD.Quantity * OD.UnitPrice) AS TotalSalesValue
FROM AdventureWorksLegacy.stg.stg_OrderDetail AS OD
JOIN AdventureWorksLegacy.stg.stg_Sale AS SA
     ON OD.SalesOrderNumber = SA.SalesOrderNumber
GROUP BY SA.CustomerKey
ORDER BY TotalSalesValue DESC;


--  Total monetário de vendas por ano
--legacy
SELECT 
    YEAR(S.OrderDate) AS Year,
    SUM(S.UnitPrice) AS TotalSalesValue
FROM AdventureWorksLegacy.dbo.Sales AS S
GROUP BY YEAR(S.OrderDate)
ORDER BY Year;

--normalizada
SELECT 
    YEAR(SA.OrderDate) AS Year,
    SUM(OD.Quantity * OD.UnitPrice) AS TotalSalesValue
FROM AdventureWorksLegacy.stg.stg_OrderDetail AS OD
JOIN AdventureWorksLegacy.stg.stg_Sale AS SA
     ON OD.SalesOrderNumber = SA.SalesOrderNumber
GROUP BY YEAR(SA.OrderDate)
ORDER BY Year;





