--Inserts nas tabelas staging

USE AdventureWorksLegacy;
GO

-- Cria Master Key só se não existir
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'PalavraPasseForte123!';

-- Cria Certificado só se não existir
IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'Cert_NIF')
    CREATE CERTIFICATE Cert_NIF WITH SUBJECT = 'Certificado para NIF';

-- Cria Chave Simétrica só se não existir
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'Key_NIF')
    CREATE SYMMETRIC KEY Key_NIF
        WITH ALGORITHM = AES_256
        ENCRYPTION BY CERTIFICATE Cert_NIF;


-- Encriptação/ criação da chave 
/**
 Executa isto apenas uma vez no setup
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'PalavraPasseForte123!';
CREATE CERTIFICATE Cert_NIF WITH SUBJECT = 'Certificado para NIF';
CREATE SYMMETRIC KEY Key_NIF
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE Cert_NIF;
**/



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

/**
SELECT DISTINCT DealerPrice, ListPrice
FROM dbo.Products
WHERE ISNUMERIC(DealerPrice) = 0 OR ISNUMERIC(ListPrice) = 0;
**/


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
    TRY_CAST(p.DealerPrice AS DECIMAL(18,2)) AS DealerPrice,
    p.StandardCost,
    p.FinishedGoodsFlag,
    p.Color,
    p.SafetyStockLevel,
    TRY_CAST(p.ListPrice AS DECIMAL(18,2)) AS ListPrice,
    p.Size,
    p.SizeRange,
    p.Weight,
    p.DaysToManufacture,
    p.ProductLine
FROM dbo.Products AS p
WHERE 
    ISNUMERIC(p.DealerPrice) = 1
    AND ISNUMERIC(p.ListPrice) = 1
    AND TRY_CAST(p.DealerPrice AS DECIMAL(18,2)) >= 1.0
    AND TRY_CAST(p.ListPrice AS DECIMAL(18,2)) >= 1.0
    AND p.ProductKey NOT IN (SELECT ProductKey FROM stg.stg_Product);
 
GO

-- Observação da verificação do numero de produtos com valor inferior a 1

SELECT COUNT(*) AS TotalOriginal FROM dbo.Products;
SELECT COUNT(*) AS TotalCarregados FROM stg.stg_Product;
SELECT COUNT(*) AS Invalidos FROM dbo.Products
WHERE ISNUMERIC(DealerPrice) = 0 OR ISNUMERIC(ListPrice) = 0
   OR TRY_CAST(DealerPrice AS DECIMAL(18,2)) < 1
   OR TRY_CAST(ListPrice AS DECIMAL(18,2)) < 1;


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


OPEN SYMMETRIC KEY Key_NIF DECRYPTION BY CERTIFICATE Cert_NIF;


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
    HASHBYTES('SHA2_512', c.Password),
    ENCRYPTBYKEY(KEY_GUID('Key_NIF'), CONVERT(nvarchar(20), c.NIF))

FROM dbo.Customer AS c
INNER JOIN stg.stg_City AS city ON c.City = city.CityName
WHERE c.CustomerKey NOT IN (SELECT CustomerKey FROM stg.stg_Customer);

CLOSE SYMMETRIC KEY Key_NIF;

-- para desencriptar
/**
OPEN SYMMETRIC KEY Key_NIF DECRYPTION BY CERTIFICATE Cert_NIF;


SELECT 
    CustomerKey,
    CONVERT(nvarchar(20), DECRYPTBYKEY(NIF)) AS NIF_Desencriptado
FROM stg.stg_Customer;

CLOSE SYMMETRIC KEY Key_NIF;
**/

 
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




GO











