SELECT COUNT(*) AS TotalProducts
FROM stg.stg_Product;


SELECT COUNT(DISTINCT SalesOrderNumber) AS TotalSalesOrders
FROM stg.stg_Sale;


SELECT
    c.CustomerKey,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    SUM(od.TotalSalesAmt) AS TotalVendas
FROM
    stg.stg_Customer c
    INNER JOIN stg.stg_Sale s ON s.CustomerKey = c.CustomerKey
    INNER JOIN stg.stg_OrderDetail od
        ON od.SalesOrderNumber = s.SalesOrderNumber AND od.SalesOrderLineNumber = s.SalesOrderLineNumber
GROUP BY
    c.CustomerKey, c.FirstName, c.LastName
ORDER BY
    TotalVendas DESC;


SELECT
    YEAR(s.OrderDate) AS Ano,
    SUM(od.TotalSalesAmt) AS TotalVendasAno
FROM
    stg.stg_Sale s
    INNER JOIN stg.stg_OrderDetail od
        ON od.SalesOrderNumber = s.SalesOrderNumber AND od.SalesOrderLineNumber = s.SalesOrderLineNumber
GROUP BY
    YEAR(s.OrderDate)
ORDER BY
    Ano;


SELECT
    YEAR(s.OrderDate) AS Ano,
    p.ProductKey,
    p.ModelName,
    SUM(od.TotalSalesAmt) AS TotalVendas
FROM
    stg.stg_Sale s
    INNER JOIN stg.stg_OrderDetail od
        ON od.SalesOrderNumber = s.SalesOrderNumber AND od.SalesOrderLineNumber = s.SalesOrderLineNumber
    INNER JOIN stg.stg_Product p
        ON od.ProductKey = p.ProductKey
GROUP BY
    YEAR(s.OrderDate), p.ProductKey, p.ModelName
ORDER BY
    Ano, p.ProductKey;


SELECT
    c.StateProvinceName AS Estado,
    SUM(od.TotalSalesAmt) AS TotalVendas
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