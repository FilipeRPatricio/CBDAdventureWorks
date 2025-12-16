use AdventureWorksLegacy

-- productSales
SELECT
    P.ModelName AS Product,
    PSC.SubCategoryName AS Category,
    SUM(OD.Quantity * OD.UnitPrice) AS TotalSales
FROM stg.stg_OrderDetail OD
JOIN stg.stg_Product P ON OD.ProductKey = P.ProductKey
JOIN stg.stg_ProductSubCategory PSC ON P.SubCategoryKey = PSC.SubCategoryKey
GROUP BY P.ModelName, PSC.SubCategoryName;

-- CustomerPurchases
SELECT
    C.CustomerKey,
    C.FirstName + ' ' + C.LastName AS CustomerName,
    COUNT(DISTINCT SA.SalesOrderNumber) AS TotalOrders,
    SUM(OD.Quantity * OD.UnitPrice) AS TotalSpent
FROM stg.stg_Customer C
JOIN stg.stg_Sale SA ON C.CustomerKey = SA.CustomerKey
JOIN stg.stg_OrderDetail OD ON SA.SalesOrderNumber = OD.SalesOrderNumber
GROUP BY C.CustomerKey, C.FirstName, C.LastName;

-- SalesSummary
SELECT
    YEAR(SA.OrderDate) AS Year,
    SUM(OD.Quantity * OD.UnitPrice) AS TotalSales
FROM stg.stg_OrderDetail OD
JOIN stg.stg_Sale SA ON OD.SalesOrderNumber = SA.SalesOrderNumber
GROUP BY YEAR(SA.OrderDate);

