/*
Grupo 5
202300133, Filipe Rodrigues Patricio
202300532, José Vicente Camolas da Silva

Inserts de dados nas tabelas staging
*/


USE AdventureWorksLegacy;
GO

-------------------------------------------------------
-- LIMPEZA DAS TABELAS STAGING 
-------------------------------------------------------

PRINT 'A limpar tabelas staging...';

BEGIN TRAN;

EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';

-- eliminar dados na ordem correta

DELETE FROM stg.stg_OrderDetail;
DELETE FROM stg.stg_Sale;
DELETE FROM stg.stg_Phone;
DELETE FROM stg.stg_SentEmails;
DELETE FROM stg.stg_User;
DELETE FROM stg.stg_Customer;
DELETE FROM stg.stg_SalesTerritory;  -- Move this before Country deletion
DELETE FROM stg.stg_Province;
DELETE FROM stg.stg_City;
DELETE FROM stg.stg_SalesTerritoryGroup;
DELETE FROM stg.stg_Country;         -- Move after SalesTerritory deletion
DELETE FROM stg.stg_Manufacturer;
DELETE FROM stg.stg_Product;
DELETE FROM stg.stg_ProductSubCategory;
DELETE FROM stg.stg_Currency;

-- reativar constraints
EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';

COMMIT TRAN;

PRINT 'Tabelas staging limpas...';

--------------------------------------------------------
-- ENCRIPTAcaO SETUP (apenas cria se nao existir)
--------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'PalavraPasseForte123!';

IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'Cert_NIF')
    CREATE CERTIFICATE Cert_NIF WITH SUBJECT = 'Certificado para NIF';

IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'Key_NIF')
    CREATE SYMMETRIC KEY Key_NIF
        WITH ALGORITHM = AES_256
        ENCRYPTION BY CERTIFICATE Cert_NIF;

---------------------------------------------
-- CURRENCY
---------------------------------------------

INSERT INTO stg.stg_Currency (CurrencyKey, CurrencyAlternateKey, CurrencyName)
SELECT DISTINCT
    c.CurrencyKey,
    c.CurrencyAlternateKey,
    c.CurrencyName
FROM dbo.Currency AS c
WHERE c.CurrencyAlternateKey IS NOT NULL
AND NOT EXISTS (
      SELECT 1 
      FROM stg.stg_Currency s
      WHERE s.CurrencyKey = c.CurrencyKey
  );

---------------------------------------------
-- MANUFACTURER
---------------------------------------------
-- Create a temporary table to hold our made-up manufacturer names
CREATE TABLE #TempManufacturers (ManuName NVARCHAR(50));
INSERT INTO #TempManufacturers (ManuName) VALUES
('ACME Corp.'),
('Globex Corporation'),
('Stark Industries'),
('Wayne Enterprises'),
('Cyberdyne Systems'),
('Buy n Large'),
('Aperture Science'),
('Sirius Cybernetics Corp.');

INSERT INTO stg.stg_Manufacturer (ManuName)
SELECT DISTINCT ManuName FROM #TempManufacturers;

IF NOT EXISTS (SELECT 1 FROM stg.stg_Manufacturer)

BEGIN
    INSERT INTO stg.stg_Manufacturer (ManuName)
    VALUES ('Unknown Manufacturer');
END


---------------------------------------------------
-- PRODUCT SUBCATEGORY 
---------------------------------------------------
INSERT INTO stg.stg_ProductSubCategory (
    SubCategoryKey, EnglishCategoryName, SubCategoryName
)
SELECT DISTINCT
    ps.ProductSubcategoryKey,
    p.EnglishProductCategoryName,
    ps.EnglishProductSubcategoryName
FROM dbo.ProductSubCategory ps LEFT JOIN dbo.Products p
    ON ps.ProductSubCategoryKey = p.ProductKey;

----------------------------------------------
-- PRODUCT
----------------------------------------------

DECLARE @DefaultManuKey INT;
SELECT @DefaultManuKey = MIN(ManuKey) FROM stg.stg_Manufacturer;


INSERT INTO stg.stg_Product (
    ProductKey, ModelName, Style, SubCategoryKey, EnglishDescription, Class,
    DealerPrice, StandardCost, FinishedGoodsFlag, Color, SafetyStockLevel, ManuKey,
    ListPrice, Size, SizeRange, Weight, DaysToManufacture, ProductLine
)
SELECT DISTINCT 
    p.ProductKey,
    p.ModelName,
    p.Style,
    p.ProductSubcategoryKey,
    p.EnglishDescription,
    p.Class,
    TRY_CAST(p.DealerPrice AS DECIMAL(18,2)),
    p.StandardCost,
    p.FinishedGoodsFlag,
    p.Color,
    p.SafetyStockLevel,
    @DefaultManuKey AS ManuKey,
    TRY_CAST(p.ListPrice AS DECIMAL(18,2)),
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
    AND TRY_CAST(p.ListPrice AS DECIMAL(18,2)) >= 1.0;

-- Drop the temporary table
DROP TABLE #TempManufacturers;


-------------------------------------------------
-- SALES TERRITORY GROUP
-------------------------------------------------
INSERT INTO stg.stg_SalesTerritoryGroup (GroupName)
SELECT DISTINCT s.SalesTerritoryGroup
FROM dbo.SalesTerritory AS s
WHERE s.SalesTerritoryGroup IS NOT NULL
  AND s.SalesTerritoryGroup NOT IN (SELECT GroupName FROM stg.stg_SalesTerritoryGroup);


---------------------------------------------
-- COUNTRY
--------------------------------------------
INSERT INTO stg.stg_Country (CountryName, CountryRegionCode)
SELECT DISTINCT
    st.SalesTerritoryCountry,
    COALESCE(c.CountryRegionCode, 'Unknown') as CountryRegionCode
FROM dbo.SalesTerritory st
LEFT JOIN dbo.Customer c ON st.SalesTerritoryCountry = c.CountryRegionName
WHERE st.SalesTerritoryCountry IS NOT NULL
AND st.SalesTerritoryCountry NOT IN (SELECT CountryName FROM stg.stg_Country);

-------------------------------------------------
-- SALES TERRITORY
-------------------------------------------------
INSERT INTO stg.stg_SalesTerritory (
    SalesTerritoryKey,
    SalesTerritoryRegion,
    CountryKey,
    GroupKey,
    StateProvinceKey
)
SELECT DISTINCT
    s.SalesTerritoryKey,
    s.SalesTerritoryRegion,
    c.CountryKey,
    g.GroupKey,
    NULL AS StateProvinceKey
FROM dbo.SalesTerritory AS s
LEFT JOIN stg.stg_Country AS c
    ON c.CountryName = s.SalesTerritoryCountry
LEFT JOIN stg.stg_SalesTerritoryGroup AS g
    ON g.GroupName = s.SalesTerritoryGroup
WHERE s.SalesTerritoryKey NOT IN (
    SELECT SalesTerritoryKey FROM stg.stg_SalesTerritory
)
AND c.CountryKey IS NOT NULL;

----------------------------------------------------
-- CITY
----------------------------------------------------
INSERT INTO stg.stg_City (CityName)
SELECT DISTINCT c.City
FROM dbo.Customer c
WHERE c.City IS NOT NULL;

-----------------------------------------------------
-- CUSTOMER
-----------------------------------------------------
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
FROM dbo.Customer c
INNER JOIN stg.stg_City city ON c.City = city.CityName;

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

-------------------------------------------------------------
-- USER
-------------------------------------------------------------
INSERT INTO stg.stg_User (
    UserKey, Email, [Password], SecurityQuestion, SecurityAnswer, DateFirstPurchase
)
SELECT 
    c.CustomerKey,
    c.EmailAddress,
    c.[Password],
    NULL AS SecurityQuestion,           -- ainda nao temos, fica NULL
    NULL AS SecurityAnswer,             -- ainda nao temos, fica NULL
    c.DateFirstPurchase
FROM stg.stg_Customer c;

-------------------------------------------------------------
-- SENT EMAILS
-------------------------------------------------------------
INSERT INTO stg.stg_SentEmails (UserKey, Receiver, Message, TimeStamp)
SELECT 
    u.UserKey,
    u.Email,
    CONCAT('Olá ', c.FirstName, ', obrigado por se registar!'),
    ISNULL(c.DateFirstPurchase, GETDATE())
FROM stg.stg_User u
JOIN stg.stg_Customer c ON u.UserKey = c.CustomerKey;

--------------------------------------------------------------
-- PHONE
--------------------------------------------------------------
INSERT INTO stg.stg_Phone (Number, CustomerKey)
SELECT DISTINCT c.Phone, c.CustomerKey
FROM dbo.Customer c
JOIN stg.stg_Customer sc ON c.CustomerKey = sc.CustomerKey
WHERE c.Phone IS NOT NULL;

--------------------------------------------------------------
-- PROVINCE
--------------------------------------------------------------
INSERT INTO stg.stg_Province (CityKey, StateProvinceName)
SELECT DISTINCT city.CityKey, c.StateProvinceName
FROM dbo.Customer c
JOIN stg.stg_City city ON c.City = city.CityName
WHERE c.StateProvinceName IS NOT NULL;


----------------------------------------------------------------
-- SALE
----------------------------------------------------------------
INSERT INTO stg.stg_Sale (
    SalesOrderNumber,
    SalesOrderLineNumber,
    OrderDate,
    DueDate,
    ShipDate,
    CustomerKey,
    CurrencyKey
)
SELECT DISTINCT
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    s.OrderDate,
    s.DueDate,
    s.ShipDate,
    s.CustomerKey,
    s.CurrencyKey
FROM dbo.Sales AS s
WHERE s.CurrencyKey IN (SELECT CurrencyKey FROM stg.stg_Currency)
  AND s.CustomerKey IN (SELECT CustomerKey FROM stg.stg_Customer)
  AND NOT EXISTS (
        SELECT 1 FROM stg.stg_Sale ss
        WHERE ss.SalesOrderNumber = s.SalesOrderNumber
          AND ss.SalesOrderLineNumber = s.SalesOrderLineNumber
    );

-----------------------------------------------------------------
-- ORDER DETAIL
-----------------------------------------------------------------
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
WHERE EXISTS (
    SELECT 1 FROM stg.stg_Sale ss
    WHERE ss.SalesOrderNumber = s.SalesOrderNumber
      AND ss.SalesOrderLineNumber = s.SalesOrderLineNumber
)
AND s.ProductKey IN (SELECT ProductKey FROM stg.stg_Product);


GO

SELECT COUNT(*) FROM stg.stg_Sale;
SELECT COUNT(*) FROM stg.stg_OrderDetail;