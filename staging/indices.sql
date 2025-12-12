use AdventureWorksLegacy


-- Query 1: vendas por cidade (total monetário)
SELECT 
    CI.CityName,
    P.StateProvinceKey AS StateCode,
    SUM(OD.Quantity * OD.UnitPrice) AS TotalSales
FROM stg.stg_OrderDetail AS OD
JOIN stg.stg_Sale       AS SA ON OD.SalesOrderNumber = SA.SalesOrderNumber
JOIN stg.stg_Customer   AS C  ON SA.CustomerKey = C.CustomerKey
JOIN stg.stg_City       AS CI ON C.CityKey = CI.CityKey
JOIN stg.stg_Province   AS P  ON CI.CityKey = P.CityKey
GROUP BY 
    CI.CityName,
    P.StateProvinceKey
ORDER BY TotalSales DESC;

-- índices para a Q1

CREATE NONCLUSTERED INDEX IX_stg_Sale_CustomerKey ON stg.stg_Sale(CustomerKey);
CREATE NONCLUSTERED INDEX IX_stg_Customer_CityKey ON stg.stg_Customer(CityKey);
CREATE NONCLUSTERED INDEX IX_stg_OrderDetail_SaleID_INCL ON stg.stg_OrderDetail(SalesOrderNumber)
    INCLUDE (Quantity, UnitPrice);


-- Query 2: produtos associados a vendas com total monetario > 1000

SELECT  
       PSC.SubCategoryName AS Categoria,
       P.ModelName         AS Produto,
       SUM(OD.Quantity * OD.UnitPrice) AS TotalVenda
FROM stg.stg_OrderDetail        AS OD
JOIN stg.stg_Product            AS P   ON OD.ProductKey = P.ProductKey
JOIN stg.stg_ProductSubCategory AS PSC ON P.SubCategoryKey = PSC.SubCategoryKey
GROUP BY 
       PSC.SubCategoryName,
       P.ModelName
HAVING 
       SUM(OD.Quantity * OD.UnitPrice) > 1000
ORDER BY 
       TotalVenda DESC;

-- Índices para Query 2 
CREATE NONCLUSTERED INDEX IX_stg_OrderDetail_SaleID_ProductKey_INCL
    ON stg.stg_OrderDetail(SalesOrderNumber, ProductKey)
    INCLUDE (Quantity, UnitPrice);


-- Query 3: numero de produtos vendidos por subcategoria por ano
SELECT 
    YEAR(SA.OrderDate) AS [Year],
    SC.SubCategoryName,
    SUM(OD.Quantity) AS ProductsSold
FROM stg.stg_OrderDetail OD
JOIN stg.stg_Sale SA ON OD.SalesOrderNumber = SA.SalesOrderNumber
JOIN stg.stg_Product P ON OD.ProductKey = P.ProductKey
JOIN stg.stg_ProductSubCategory SC ON P.SubCategoryKey = SC.SubCategoryKey
GROUP BY YEAR(SA.OrderDate), SC.SubCategoryName
ORDER BY [Year], ProductsSold DESC;


-- Índices para Query 3 (produtos por categoria por ano)

CREATE NONCLUSTERED INDEX IX_stg_OrderDetail_ProductKey_INCL
    ON stg.stg_OrderDetail(ProductKey)
    INCLUDE (Quantity, SalesOrderNumber);

CREATE NONCLUSTERED INDEX IX_stg_Sale_OrderDate_INCL
    ON stg.stg_Sale(OrderDate)
    INCLUDE (SalesOrderNumber);


-- drop dos indices
DROP INDEX IF EXISTS IX_stg_OrderDetail_SaleID_INCL ON stg.stg_OrderDetail;
DROP INDEX IF EXISTS IX_stg_OrderDetail_SaleID_ProductKey_INCL ON stg.stg_OrderDetail;
DROP INDEX IF EXISTS IX_stg_OrderDetail_ProductKey_INCL ON stg.stg_OrderDetail;

DROP INDEX IF EXISTS IX_stg_Sale_CustomerKey ON stg.stg_Sale;
DROP INDEX IF EXISTS IX_stg_Sale_OrderDate_INCL ON stg.stg_Sale;

DROP INDEX IF EXISTS IX_stg_Customer_CityKey ON stg.stg_Customer;
