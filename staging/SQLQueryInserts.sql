--Inserts nas tabelas staging

USE AdventureWorksLegacy;
GO


--CURRENCY --------------------------------------------------------------------------------
INSERT INTO stg.stg_Currency (CurrencyAlternateKey, CurrencyName)
SELECT DISTINCT 
    c.CurrencyAlternateKey, 
    c.CurrencyName
FROM dbo.Currency AS c
WHERE c.CurrencyAlternateKey NOT IN ( -- evita inserir algo que já esteja na tabela staging
    SELECT CurrencyAlternateKey 
    FROM stg.stg_Currency
);

-- PRODUCT SUBCATEGORY --------------------------------TOU A TER PROBLEMAS AQUI ------------
INSERT INTO stg.stg_ProductSubCategory (                -- diz me que o EnglishCategoryName ta a null em toda a coluna
    SubCategoryKey,
    EnglishCategoryName,
    SubCategoryName
)
SELECT DISTINCT
    ps.ProductSubcategoryKey AS SubCategoryKey,
    p.EnglishProductCategoryName AS EnglishCategoryName,
    ps.EnglishProductSubcategoryName AS SubCategoryName
FROM dbo.ProductSubCategory ps
LEFT JOIN dbo.Products p
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
WHERE ps.ProductSubcategoryKey IS NOT NULL
  AND ps.ProductSubcategoryKey NOT IN (SELECT SubCategoryKey FROM stg.stg_ProductSubCategory);

-- PRODUCTS -------------------------------------------------------------------------------
INSERT INTO stg.stg_Product (
    ProductKey, ModelName, Style, SubCategoryKey, EnglishDescription, Class,
    DealerPrice, StandardCost, FinishedGoodsFlag, Color, SafetyStockLevel,
    ListPrice, Size, SizeRange, Weight, DaysToManufacture, ProductLine
)
SELECT DISTINCT 
    p.ProductKey,
    p.ModelName,
    p.Style,
    p.ProductSubcategoryKey AS SubCategoryKey,
    p.EnglishDescription,
    p.Class,
    p.DealerPrice,
    p.StandardCost,
    p.FinishedGoodsFlag,
    p.Color,
    p.SafetyStockLevel,
    p.ListPrice,
    p.Size,
    p.SizeRange,
    p.Weight,
    p.DaysToManufacture,
    p.ProductLine
FROM dbo.Products AS p
WHERE p.ProductKey NOT IN (SELECT ProductKey FROM stg.stg_Product);  
GO

-- MANUFACTURER -------------------------------------------------------------------------------
INSERT INTO stg.stg_Manufacturer (
ProductKey,
ManuName
)
SELECT DISTINCT
    p.ProductKey,
    NULL AS ManuName
FROM stg.stg_Product AS p;

--insert simples para testar

UPDATE stg.stg_Manufacturer
SET ManuName = 'Mike'
WHERE ProductKey IN (SELECT ProductKey FROM stg.stg_Product WHERE ProductLine = 'M');

-- SALES TERRITORY GROUP ---------------------------------------------------------------------------

INSERT INTO stg.stg_SalesTerritoryGroup (
    GroupName
    )
    SELECT DISTINCT
        s.GroupName
    FROM stg.stg_SalesTerritoryGroup AS s

-- COUNTRY --------------------------------------------------------------------------------------------

INSERT INTO stg.stg_Country (
    CountryName,
    CountryRegionCode
)
SELECT DISTINCT
    c.CountryRegionName AS CountryName,
    c.CountryRegionCode
FROM dbo.Customer AS c;

-- CITY --------------------------------------------------------------------------------------------

INSERT INTO stg.stg_City (CityName)
SELECT DISTINCT c.City
FROM dbo.Customer AS c
WHERE c.City IS NOT NULL
  AND c.City NOT IN (SELECT CityName FROM stg.stg_City);


-- CUSTOMER -------------------------------------------------------------------------------------------

INSERT INTO stg.stg_Customer (
    CustomerKey, Title, FirstName, MiddleName, LastName, BirthDate, MaritalStatus, Gender,
    EmailAddress, YearlyIncome, Education, Occupation, NumberCarsOwned, AddressLine1, CityKey,
    StateProvinceCode, StateProvinceName, CountryRegionCode, CountryRegionName, PostalCode,
    SalesTerritoryKey, Phone, DateFirstPurchase, [Password], NIF
)
SELECT
    c.CustomerKey,
    c.Title,
    c.FirstName,
    c.MiddleName,
    c.LastName,
    c.BirthDate,
    c.MaritalStatus,
    c.Gender,
    c.EmailAddress,
    c.YearlyIncome,
    c.Education,
    c.Occupation,
    c.NumberCarsOwned,
    c.AddressLine1,
    city.CityKey,                 
    c.StateProvinceCode,
    c.StateProvinceName,
    c.CountryRegionCode,
    c.CountryRegionName,
    c.PostalCode,
    c.SalesTerritoryKey,
    c.Phone,
    c.DateFirstPurchase,
    c.Password,
    c.NIF
FROM dbo.Customer AS c
INNER JOIN stg.stg_City AS city ON c.City = city.CityName
WHERE c.CustomerKey NOT IN (SELECT CustomerKey FROM stg.stg_Customer);  
 
 -- USER -------------------------------------------------------------------------------------------------

 INSERT INTO stg.stg_User (
    UserKey,
    Email,
    [Password],
    SecurityQuestion,
    SecurityAnswer,
    DateFirstPurchase
)
SELECT 
    c.CustomerKey AS UserKey,           
    c.EmailAddress AS Email,            
    c.[Password],                       
    NULL AS SecurityQuestion,           -- ainda não temos, fica NULL
    NULL AS SecurityAnswer,             -- ainda não temos, fica NULL
    c.DateFirstPurchase                 
FROM stg.stg_Customer AS c
WHERE c.CustomerKey NOT IN (SELECT UserKey FROM stg.stg_User);

-- SENT EMAILS ---------------------------------------------------------------------------------------------

INSERT INTO stg.stg_SentEmails (UserKey, Receiver, Message, TimeStamp)
SELECT 
    u.UserKey,
    u.Email,
    CONCAT('Olá ', c.FirstName, ', obrigado por se registar!') AS Message,
    ISNULL(c.DateFirstPurchase, GETDATE()) AS TimeStamp
FROM stg.stg_User AS u
INNER JOIN stg.stg_Customer AS c
    ON u.UserKey = c.CustomerKey
WHERE u.Email IS NOT NULL;


-- SELECT * FROM stg.stg_SentEmails;

-- PHONE -----------------------------------------------------------------------------------------------------

INSERT INTO stg.stg_Phone (Number, CustomerKey)
SELECT DISTINCT
    c.Phone AS Number,
    c.CustomerKey
FROM dbo.Customer AS c
INNER JOIN stg.stg_Customer AS sc ON c.CustomerKey = sc.CustomerKey
WHERE c.Phone IS NOT NULL
  AND c.CustomerKey NOT IN (
        SELECT CustomerKey FROM stg.stg_Phone
    );

-- PROVINCE ---------------------------------------------------------------------------------------
INSERT INTO stg.stg_Province (CityKey, StateProvinceName)
SELECT DISTINCT   
    city.CityKey,                               
    c.StateProvinceName                         
FROM dbo.Customer AS c
INNER JOIN stg.stg_City AS city 
    ON c.City = city.CityName                   
WHERE c.StateProvinceName IS NOT NULL
  AND c.StateProvinceName NOT IN (
        SELECT StateProvinceName FROM stg.stg_Province
    );

-- SALE-----------------------------------------------------------------------------------------------
INSERT INTO stg.stg_Sale (
    SalesOrderNumber,
    OrderDate,
    DueDate,
    ShipDate,
    CustomerKey,
    CurrencyKey,
    SalesOrderLineNumber
)
SELECT 
    s.SalesOrderNumber,
    s.OrderDate,
    s.DueDate,
    s.ShipDate,
    s.CustomerKey,
    s.CurrencyKey,
    s.SalesOrderLineNumber
FROM dbo.Sales AS s
WHERE s.SalesOrderNumber NOT IN (
    SELECT SalesOrderNumber FROM stg.stg_Sale
);

-- ORDERDETAIL --------------------------------------------------------------------------------------
INSERT INTO stg.stg_OrderDetail (
    SalesOrderNumber,
    SalesOrderLineNumber,
    ProductKey,
    TaxAmt,
    UnitPrice,
    Quantity,
    Freight,
    ProductStandardAmt
)
SELECT DISTINCT
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    s.ProductKey,
    s.TaxAmt,
    s.UnitPrice,
    1 AS Quantity,  
    s.Freight,
    s.ProductStandardCost AS ProductStandardAmt
FROM dbo.Sales AS s
WHERE NOT EXISTS (
    SELECT 1 
    FROM stg.stg_OrderDetail od
    WHERE od.SalesOrderNumber = s.SalesOrderNumber
      AND od.SalesOrderLineNumber = s.SalesOrderLineNumber
);

select * from stg.stg_OrderDetail






GO











