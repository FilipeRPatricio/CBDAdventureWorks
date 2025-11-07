/*
Grupo 5
202300133, Filipe Rodrigues Patricio
202300532, José Vicente Camolas da Silva

Procedures para manipulação das tabelas staging
*/

-- COUNTRY PROCEDURES
CREATE OR ALTER PROCEDURE stg.usp_AddCountry
    @CountryName NVARCHAR(100),
    @CountryRegionCode NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO stg.stg_Country (CountryName, CountryRegionCode)
        VALUES (@CountryName, @CountryRegionCode);
        
        SELECT 'Country added successfully' AS Message, SCOPE_IDENTITY() AS CountryKey;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE stg.usp_DeleteCountry
    @CountryKey INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM stg.stg_Country WHERE CountryKey = @CountryKey;
        
        IF @@ROWCOUNT = 0
            SELECT 'Country not found' AS Message;
        ELSE
            SELECT 'Country deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- SALES TERRITORY GROUP PROCEDURES
CREATE OR ALTER PROCEDURE stg.usp_AddSalesTerritoryGroup
    @GroupName NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO stg.stg_SalesTerritoryGroup (GroupName)
        VALUES (@GroupName);
        
        SELECT 'Sales Territory Group added successfully' AS Message, SCOPE_IDENTITY() AS GroupKey;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE stg.usp_DeleteSalesTerritoryGroup
    @GroupKey INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM stg.stg_SalesTerritoryGroup WHERE GroupKey = @GroupKey;
        
        IF @@ROWCOUNT = 0
            SELECT 'Sales Territory Group not found' AS Message;
        ELSE
            SELECT 'Sales Territory Group deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- CUSTOMER PROCEDURES
CREATE OR ALTER PROCEDURE stg.usp_AddCustomer
    @CustomerKey INT,
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @BirthDate DATE,
    @Title NVARCHAR(10) = NULL,
    @MiddleName NVARCHAR(50) = NULL,
    @MaritalStatus CHAR(1) = NULL,
    @Gender CHAR(1) = NULL,
    @EmailAddress NVARCHAR(100) = NULL,
    @YearlyIncome DECIMAL(18,2) = NULL,
    @Education NVARCHAR(50) = NULL,
    @Occupation NVARCHAR(100) = NULL,
    @NumberCarsOwned TINYINT = NULL,
    @AddressLine1 NVARCHAR(100) = NULL,
    @CityKey INT,
    @StateProvinceCode NVARCHAR(10) = NULL,
    @StateProvinceName NVARCHAR(100) = NULL,
    @CountryRegionCode NVARCHAR(10) = NULL,
    @CountryRegionName NVARCHAR(100) = NULL,
    @PostalCode NVARCHAR(20) = NULL,
    @SalesTerritoryKey INT = NULL,
    @Phone NVARCHAR(25) = NULL,
    @DateFirstPurchase DATE = NULL,
    @Password VARBINARY(64) = NULL,
    @NIF VARBINARY(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO stg.stg_Customer (
            CustomerKey, Title, FirstName, MiddleName, LastName, BirthDate,
            MaritalStatus, Gender, EmailAddress, YearlyIncome, Education,
            Occupation, NumberCarsOwned, AddressLine1, CityKey, StateProvinceCode,
            StateProvinceName, CountryRegionCode, CountryRegionName, PostalCode,
            SalesTerritoryKey, Phone, DateFirstPurchase, [Password], NIF
        )
        VALUES (
            @CustomerKey, @Title, @FirstName, @MiddleName, @LastName, @BirthDate,
            @MaritalStatus, @Gender, @EmailAddress, @YearlyIncome, @Education,
            @Occupation, @NumberCarsOwned, @AddressLine1, @CityKey, @StateProvinceCode,
            @StateProvinceName, @CountryRegionCode, @CountryRegionName, @PostalCode,
            @SalesTerritoryKey, @Phone, @DateFirstPurchase, @Password, @NIF
        );
        
        SELECT 'Customer added successfully' AS Message, @CustomerKey AS CustomerKey;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE stg.usp_DeleteCustomer
    @CustomerKey INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM stg.stg_Customer WHERE CustomerKey = @CustomerKey;
        
        IF @@ROWCOUNT = 0
            SELECT 'Customer not found' AS Message;
        ELSE
            SELECT 'Customer deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

  
-- USER PROCEDURES
CREATE OR ALTER PROCEDURE stg.usp_AddUser
    @UserKey INT,
    @Email NVARCHAR(100),
    @Password NVARCHAR(255),
    @SecurityQuestion NVARCHAR(255) = NULL,
    @SecurityAnswer NVARCHAR(255) = NULL,
    @DateFirstPurchase DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO stg.stg_User (UserKey, Email, [Password], SecurityQuestion, SecurityAnswer, DateFirstPurchase)
        VALUES (@UserKey, @Email, @Password, @SecurityQuestion, @SecurityAnswer, @DateFirstPurchase);
        
        SELECT 'User added successfully' AS Message, @UserKey AS UserKey;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE stg.usp_DeleteUser
    @UserKey INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM stg.stg_User WHERE UserKey = @UserKey;
        
        IF @@ROWCOUNT = 0
            SELECT 'User not found' AS Message;
        ELSE
            SELECT 'User deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO


-- SENT EMAILS PROCEDURES
  
CREATE OR ALTER PROCEDURE stg.usp_AddSentEmail
    @UserKey INT,
    @Receiver NVARCHAR(100),
    @Message NVARCHAR(255),
    @TimeStamp DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO stg.stg_SentEmails (UserKey, Receiver, Message, TimeStamp)
        VALUES (@UserKey, @Receiver, @Message, ISNULL(@TimeStamp, GETDATE()));
        
        SELECT 'Email record added successfully' AS Message, SCOPE_IDENTITY() AS EmailId;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE stg.usp_DeleteSentEmail
    @EmailId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM stg.stg_SentEmails WHERE EmailId = @EmailId;
        
        IF @@ROWCOUNT = 0
            SELECT 'Email record not found' AS Message;
        ELSE
            SELECT 'Email record deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO


-- PHONE PROCEDURES
  
CREATE OR ALTER PROCEDURE stg.usp_AddPhone
    @Number NVARCHAR(50),
    @CustomerKey INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO stg.stg_Phone (Number, CustomerKey)
        VALUES (@Number, @CustomerKey);
        
        SELECT 'Phone added successfully' AS Message;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE stg.usp_DeletePhone
    @Number NVARCHAR(50),
    @CustomerKey INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM stg.stg_Phone WHERE Number = @Number AND CustomerKey = @CustomerKey;
        
        IF @@ROWCOUNT = 0
            SELECT 'Phone not found' AS Message;
        ELSE
            SELECT 'Phone deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- CITY PROCEDURES
  
CREATE OR ALTER PROCEDURE stg.usp_AddCity
    @CityName NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO stg.stg_City (CityName)
        VALUES (@CityName);
        
        SELECT 'City added successfully' AS Message, SCOPE_IDENTITY() AS CityKey;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE stg.usp_DeleteCity
    @CityKey INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM stg.stg_City WHERE CityKey = @CityKey;
        
        IF @@ROWCOUNT = 0
            SELECT 'City not found' AS Message;
        ELSE
            SELECT 'City deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- PROVINCE PROCEDURES
  
CREATE OR ALTER PROCEDURE stg.usp_AddProvince
    @CityKey INT,
    @StateProvinceName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO stg.stg_Province (CityKey, StateProvinceName)
        VALUES (@CityKey, @StateProvinceName);
        
        SELECT 'Province added successfully' AS Message, SCOPE_IDENTITY() AS StateProvinceKey;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE stg.usp_DeleteProvince
    @StateProvinceKey INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM stg.stg_Province WHERE StateProvinceKey = @StateProvinceKey;
        
        IF @@ROWCOUNT = 0
            SELECT 'Province not found' AS Message;
        ELSE
            SELECT 'Province deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- CURRENCY PROCEDURES

CREATE OR ALTER PROCEDURE stg.usp_AddCurrency
    @CurrencyKey INT,
    @CurrencyAlternateKey NVARCHAR(50),
    @CurrencyName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO stg.stg_Currency (CurrencyKey, CurrencyAlternateKey, CurrencyName)
        VALUES (@CurrencyKey, @CurrencyAlternateKey, @CurrencyName);
        
        SELECT 'Currency added successfully' AS Message, @CurrencyKey AS CurrencyKey;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE stg.usp_DeleteCurrency
    @CurrencyKey INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM stg.stg_Currency WHERE CurrencyKey = @CurrencyKey;
        
        IF @@ROWCOUNT = 0
            SELECT 'Currency not found' AS Message;
        ELSE
            SELECT 'Currency deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO


-- PRODUCT PROCEDURES
CREATE OR ALTER PROCEDURE stg.usp_AddProduct
    @ProductKey INT,
    @ModelName NVARCHAR(100) = NULL,
    @Style NCHAR(2) = NULL,
    @SubCategoryKey INT = NULL,
    @EnglishDescription NVARCHAR(400) = NULL,
    @Class NCHAR(2) = NULL,
    @DealerPrice DECIMAL(18,2) = NULL,
    @StandardCost DECIMAL(18,2) = NULL,
    @FinishedGoodsFlag BIT = 1,
    @Color NVARCHAR(20) = NULL,
    @SafetyStockLevel SMALLINT = NULL,
    @ListPrice DECIMAL(18,2) = NULL,
    @Size NVARCHAR(10) = NULL,
    @SizeRange NVARCHAR(25) = NULL,
    @Weight DECIMAL(10,2) = NULL,
    @DaysToManufacture SMALLINT = NULL,
    @ProductLine NCHAR(2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO stg.stg_Product (
            ProductKey, ModelName, Style, SubCategoryKey, EnglishDescription,
            Class, DealerPrice, StandardCost, FinishedGoodsFlag, Color,
            SafetyStockLevel, ListPrice, Size, SizeRange, Weight,
            DaysToManufacture, ProductLine
        )
        VALUES (
            @ProductKey, @ModelName, @Style, @SubCategoryKey, @EnglishDescription,
            @Class, @DealerPrice, @StandardCost, @FinishedGoodsFlag, @Color,
            @SafetyStockLevel, @ListPrice, @Size, @SizeRange, @Weight,
            @DaysToManufacture, @ProductLine
        );
        
        SELECT 'Product added successfully' AS Message, @ProductKey AS ProductKey;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE stg.usp_DeleteProduct
    @ProductKey INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM stg.stg_Product WHERE ProductKey = @ProductKey;
        
        IF @@ROWCOUNT = 0
            SELECT 'Product not found' AS Message;
        ELSE
            SELECT 'Product deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- PRODUCT SUBCATEGORY PROCEDURES
CREATE OR ALTER PROCEDURE stg.usp_AddProductSubCategory
    @SubCategoryKey INT,
    @ProductKey INT,
    @EnglishCategoryName NVARCHAR(100) = NULL,
    @SubCategoryName NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO stg.stg_ProductSubCategory (SubCategoryKey, ProductKey, EnglishCategoryName, SubCategoryName)
        VALUES (@SubCategoryKey, @ProductKey, @EnglishCategoryName, @SubCategoryName);
        
        SELECT 'Product SubCategory added successfully' AS Message, @SubCategoryKey AS SubCategoryKey;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE stg.usp_DeleteProductSubCategory
    @SubCategoryKey INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM stg.stg_ProductSubCategory WHERE SubCategoryKey = @SubCategoryKey;
        
        IF @@ROWCOUNT = 0
            SELECT 'Product SubCategory not found' AS Message;
        ELSE
            SELECT 'Product SubCategory deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO


-- MANUFACTURER PROCEDURES
CREATE OR ALTER PROCEDURE stg.usp_AddManufacturer
    @ProductKey INT,
    @ManuName NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO stg.stg_Manufacturer (ProductKey, ManuName)
        VALUES (@ProductKey, @ManuName);
        
        SELECT 'Manufacturer added successfully' AS Message, SCOPE_IDENTITY() AS ManuKey;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE stg.usp_DeleteManufacturer
    @ManuKey INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM stg.stg_Manufacturer WHERE ManuKey = @ManuKey;
        
        IF @@ROWCOUNT = 0
            SELECT 'Manufacturer not found' AS Message;
        ELSE
            SELECT 'Manufacturer deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- SALES TERRITORY PROCEDURES
CREATE OR ALTER PROCEDURE stg.usp_AddSalesTerritory
    @SalesTerritoryKey INT,
    @SalesTerritoryRegion NVARCHAR(100),
    @CountryKey INT,
    @GroupKey INT,
    @StateProvinceKey INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO stg.stg_SalesTerritory (SalesTerritoryKey, SalesTerritoryRegion, CountryKey, GroupKey, StateProvinceKey)
        VALUES (@SalesTerritoryKey, @SalesTerritoryRegion, @CountryKey, @GroupKey, @StateProvinceKey);
        
        SELECT 'Sales Territory added successfully' AS Message, @SalesTerritoryKey AS SalesTerritoryKey;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE stg.usp_DeleteSalesTerritory
    @SalesTerritoryKey INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM stg.stg_SalesTerritory WHERE SalesTerritoryKey = @SalesTerritoryKey;
        
        IF @@ROWCOUNT = 0
            SELECT 'Sales Territory not found' AS Message;
        ELSE
            SELECT 'Sales Territory deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- SALE PROCEDURES
CREATE OR ALTER PROCEDURE stg.usp_AddSale
    @SalesOrderNumber NVARCHAR(20),
    @OrderDate DATE,
    @CustomerKey INT,
    @CurrencyKey INT,
    @DueDate DATE = NULL,
    @ShipDate DATE = NULL,
    @SalesOrderLineNumber INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO stg.stg_Sale (SalesOrderNumber, OrderDate, DueDate, ShipDate, CustomerKey, CurrencyKey, SalesOrderLineNumber)
        VALUES (@SalesOrderNumber, @OrderDate, @DueDate, @ShipDate, @CustomerKey, @CurrencyKey, @SalesOrderLineNumber);
        
        SELECT 'Sale added successfully' AS Message, @SalesOrderNumber AS SalesOrderNumber, @SalesOrderLineNumber AS SalesOrderLineNumber;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE stg.usp_DeleteSale
    @SalesOrderNumber INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM stg.stg_Sale WHERE SalesOrderNumber = @SalesOrderNumber;
        
        IF @@ROWCOUNT = 0
            SELECT 'Sale not found' AS Message;
        ELSE
            SELECT 'Sale deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- ORDER DETAIL PROCEDURES
CREATE OR ALTER PROCEDURE stg.usp_AddOrderDetail
    @SalesOrderNumber NVARCHAR(20),
    @SalesOrderLineNumber INT,
    @ProductKey INT,
    @UnitPrice DECIMAL(10,2),
    @Quantity INT,
    @TaxAmt DECIMAL(10,2) = NULL,
    @Freight DECIMAL(10,2) = NULL,
    @ProductStandardAmt DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO stg.stg_OrderDetail (
            SalesOrderNumber, SalesOrderLineNumber, ProductKey, TaxAmt,
            UnitPrice, Quantity, Freight, ProductStandardAmt
        )
        VALUES (
            @SalesOrderNumber, @SalesOrderLineNumber, @ProductKey, @TaxAmt,
            @UnitPrice, @Quantity, @Freight, @ProductStandardAmt
        );
        
        SELECT 'Order Detail added successfully' AS Message, SCOPE_IDENTITY() AS OrderDetailKey;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
