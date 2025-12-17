/*
Grupo 5 
202300133, Filipe Rodrigues Patricio 
202300532, José Vicente Camolas da Silva 

Criação da stg schema e criação das tabelas staging
*/


USE AdventureWorksLegacy;
GO

--criar schema se ainda no existir
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'stg')
    EXEC('CREATE SCHEMA stg;');
GO

--se a tabela j existir, elimina-a 

IF OBJECT_ID('stg.stg_OrderDetail', 'U') IS NOT NULL
    DROP TABLE stg.stg_OrderDetail;

IF OBJECT_ID('stg.stg_Sale', 'U') IS NOT NULL
    DROP TABLE stg.stg_Sale;

IF OBJECT_ID('stg.stg_Currency', 'U') IS NOT NULL
    DROP TABLE stg.stg_Currency;

IF OBJECT_ID('stg.stg_SalesTerritory', 'U') IS NOT NULL
    DROP TABLE stg.stg_SalesTerritory;

IF OBJECT_ID('stg.stg_Country', 'U') IS NOT NULL
    DROP TABLE stg.stg_Country;

IF OBJECT_ID('stg.stg_SentEmails', 'U') IS NOT NULL
    DROP TABLE stg.stg_SentEmails

IF OBJECT_ID('stg.stg_User', 'U') IS NOT NULL
    DROP TABLE stg.stg_User;

IF OBJECT_ID('stg.stg_Province', 'U') IS NOT NULL
    DROP TABLE stg.stg_Province;

IF OBJECT_ID('stg.stg_Phone', 'U') IS NOT NULL
    DROP TABLE stg.stg_Phone;

IF OBJECT_ID('stg.stg_Customer', 'U') IS NOT NULL
    DROP TABLE stg.stg_Customer;

IF OBJECT_ID('stg.stg_City', 'U') IS NOT NULL
    DROP TABLE stg.stg_City;

IF OBJECT_ID('stg.stg_SalesTerritoryGroup', 'U') IS NOT NULL
    DROP TABLE stg.stg_SalesTerritoryGroup;

IF OBJECT_ID('stg.stg_Product', 'U') IS NOT NULL
    DROP TABLE stg.stg_Product;

IF OBJECT_ID('stg.stg_Manufacturer', 'U') IS NOT NULL
    DROP TABLE stg.stg_Manufacturer;

IF OBJECT_ID('stg.stg_ProductSubCategory', 'U') IS NOT NULL
    DROP TABLE stg.stg_ProductSubCategory;

GO




-- COUNTRY --------------------------------------------------------------------------------------
CREATE TABLE stg.stg_Country (
    CountryKey INT IDENTITY(1,1) PRIMARY KEY,                
    CountryName NVARCHAR(100) NOT NULL,        
    CountryRegionCode NVARCHAR(10) NULL        
);
GO

-- SALES TERRITORY GROUP ---------------------------------------------------------------------------
CREATE TABLE stg.stg_SalesTerritoryGroup (
    GroupKey INT IDENTITY(1,1) PRIMARY KEY,                  
    GroupName NVARCHAR(100) NOT NULL           
);
GO


-- CITY -----------------------------------------------------------------------------------------
CREATE TABLE stg.stg_City (
    CityKey INT IDENTITY(1,1) PRIMARY KEY,
    CityName NVARCHAR(100) NOT NULL UNIQUE
);
GO

-- CUSTOMER --------------------------------------------------------------------------------

OPEN SYMMETRIC KEY Key_NIF DECRYPTION BY CERTIFICATE Cert_NIF;

CREATE TABLE stg.stg_Customer (
    CustomerKey INT PRIMARY KEY,    
    Title NVARCHAR(10) NULL,
    FirstName NVARCHAR(50) NOT NULL,
    MiddleName NVARCHAR(50) NULL,
    LastName NVARCHAR(50) NOT NULL,
    BirthDate DATE NOT NULL,
    MaritalStatus CHAR(1) NULL,                      
    Gender CHAR(1) NULL,                         
    EmailAddress NVARCHAR(100) NULL,
    YearlyIncome DECIMAL(18,2) NULL,
    Education NVARCHAR(50) NULL,
    Occupation NVARCHAR(100) NULL,
    NumberCarsOwned TINYINT NULL,
    AddressLine1 NVARCHAR(100) NULL,
    CityKey INT NOT NULL,
    StateProvinceCode NVARCHAR(10) NULL,
    StateProvinceName NVARCHAR(100) NULL,
    CountryRegionCode NVARCHAR(10) NULL,
    CountryRegionName NVARCHAR(100) NULL,
    PostalCode NVARCHAR(20) NULL,
    SalesTerritoryKey INT NULL,                     
    Phone NVARCHAR(25) NULL,
    DateFirstPurchase DATE NULL,
    [Password] VARBINARY(64) NULL,       
    NIF VARBINARY(MAX) NULL,

    CONSTRAINT FK_Customer_City FOREIGN KEY (CityKey)
        REFERENCES stg.stg_City(CityKey)

    
);


-- USER -------------------------------------------------------------------------------------
CREATE TABLE stg.stg_User (
    UserKey INT PRIMARY KEY,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    [Password] NVARCHAR(255) NOT NULL,
    SecurityQuestion NVARCHAR(255),
    SecurityAnswer NVARCHAR(255),
    DateFirstPurchase DATE,

     CONSTRAINT FK_User_Customer
        FOREIGN KEY (UserKey)
        REFERENCES stg.stg_Customer(CustomerKey)
);
GO

-- SENT EMAILS ------------------------------------------------------------------------------
CREATE TABLE stg.stg_SentEmails (
    EmailId INT IDENTITY(1,1) PRIMARY KEY,
    UserKey INT NOT NULL,
    Receiver NVARCHAR(100) NOT NULL,
    Message NVARCHAR(255) NOT NULL,
    TimeStamp DATE,

     CONSTRAINT FK_SentEmails_User
        FOREIGN KEY (UserKey)
        REFERENCES stg.stg_User(UserKey)
);
GO

-- PHONE ------------------------------------------------------------------------------------
CREATE TABLE stg.stg_Phone (
    Number NVARCHAR(50),
    CustomerKey INT NOT NULL,

    CONSTRAINT FK_Phone_Customer
        FOREIGN KEY (CustomerKey)
        REFERENCES stg.stg_Customer(CustomerKey)
    );



-- PROVINCE ---------------------------------------------------------------------------------------
CREATE TABLE stg.stg_Province (
    StateProvinceKey INT IDENTITY(1,1) PRIMARY KEY,
    CityKey INT NOT NULL,
    StateProvinceName NVARCHAR(50),

    CONSTRAINT FK_Province_City
        FOREIGN KEY (CityKey)
        REFERENCES stg.stg_City(CityKey)
);

-- CURRENCY -----------------------------------------------------------------------------------------
CREATE TABLE stg.stg_Currency (
    CurrencyKey INT PRIMARY KEY,
    CurrencyAlternateKey NVARCHAR(50) UNIQUE,
    CurrencyName NVARCHAR(50)
);
GO

-- PRODUCT SUBCATEGORY ----------------------------------------------------------------------------
CREATE TABLE stg.stg_ProductSubCategory (
    SubCategoryKey INT PRIMARY KEY,                    
    EnglishCategoryName NVARCHAR(100) NULL,            
    SubCategoryName NVARCHAR(100) NULL
);
GO

-- MANUFACTURER ------------------------------------------------------------------------------------
CREATE TABLE stg.stg_Manufacturer (
    ManuKey INT IDENTITY(1,1) PRIMARY KEY,
    ManuName NVARCHAR(100)
);
GO

-- PRODUCTS --------------------------------------------------------------------------------------
CREATE TABLE stg.stg_Product (
    ProductKey INT PRIMARY KEY,     
    ModelName NVARCHAR(100) NULL,               
    Style NCHAR(2) NULL,                        
    SubCategoryKey INT NULL,  -- FK PARA SubCategory                   
    EnglishDescription NVARCHAR(400) NULL,      
    Class NCHAR(2) NULL,                        
    DealerPrice DECIMAL(18,2) NULL,             
    StandardCost DECIMAL(18,2) NULL,            
    FinishedGoodsFlag BIT NOT NULL DEFAULT 1,   
    Color NVARCHAR(20) NULL,                    
    SafetyStockLevel SMALLINT NULL,             
    ListPrice DECIMAL(18,2) NULL,               
    Size NVARCHAR(10) NULL,                   
    SizeRange NVARCHAR(25) NULL,                
    Weight DECIMAL(10,2) NULL,                  
    DaysToManufacture SMALLINT NULL,            
    ProductLine NCHAR(2) NULL, 
    ManuKey INT NOT NULL,

    CONSTRAINT FK_Product_SubCategory
        FOREIGN KEY (SubCategoryKey)
        REFERENCES stg.stg_ProductSubCategory(SubCategoryKey),
    
    CONSTRAINT FK_Product_Manufacturer
        FOREIGN KEY (ManuKey)
        REFERENCES stg.stg_Manufacturer(ManuKey)
);

-- verificao que dealer price e list price tem que ser > 1
ALTER TABLE stg.stg_Product
ADD CONSTRAINT CK_Product_MinPrices
CHECK (DealerPrice >= 1.0 AND ListPrice >=1.0);

GO

-- SALES TERRITORY -------------------------------------------------------------------------------------
CREATE TABLE stg.stg_SalesTerritory (
    SalesTerritoryKey INT PRIMARY KEY,
    SalesTerritoryRegion NVARCHAR(100) NOT NULL, 
    CountryKey INT NOT NULL,                             
    GroupKey INT NOT NULL,                               
    StateProvinceKey INT NULL,                           

    CONSTRAINT FK_SalesTerritory_Country 
        FOREIGN KEY (CountryKey)
        REFERENCES stg.stg_Country(CountryKey),

    CONSTRAINT FK_SalesTerritory_Group 
        FOREIGN KEY (GroupKey)
        REFERENCES stg.stg_SalesTerritoryGroup(GroupKey),

    CONSTRAINT FK_SalesTerritory_Province
        FOREIGN KEY (StateProvinceKey)
        REFERENCES stg.stg_Province(StateProvinceKey)
);
GO

-- SALE ---------------------------------------------------------------------------------------------
CREATE TABLE stg.stg_Sale (
    SalesOrderNumber NVARCHAR(20) NOT NULL, 
    SalesOrderLineNumber INT NOT NULL,
    OrderDate DATE NOT NULL,
    DueDate DATE NULL,  
    ShipDate DATE NULL,  
    CustomerKey INT NOT NULL,
    CurrencyKey INT NOT NULL,

    CONSTRAINT PK_Sale PRIMARY KEY (SalesOrderNumber, SalesOrderLineNumber),

    CONSTRAINT FK_Sale_Customer 
        FOREIGN KEY (CustomerKey)
        REFERENCES stg.stg_Customer(CustomerKey),

    CONSTRAINT FK_Sale_Currency 
        FOREIGN KEY (CurrencyKey)
        REFERENCES stg.stg_Currency(CurrencyKey)
);
GO

-- ORDER DETAIL -------------------------------------------------------------------------------------
CREATE TABLE stg.stg_OrderDetail (
    OrderDetailKey INT IDENTITY(1,1) PRIMARY KEY,   
    SalesOrderNumber NVARCHAR(20) NOT NULL,
    SalesOrderLineNumber INT NOT NULL,       -- adicionamos isto!
    ProductKey INT NOT NULL,                 
    TaxAmt DECIMAL(10,2) NULL, 
    UnitPrice DECIMAL(10,2) NOT NULL,  
    Quantity INT NOT NULL,   
    TotalSalesAmt AS (UnitPrice * Quantity + ISNULL(TaxAmt,0)) PERSISTED,
    Freight DECIMAL(10,2) NULL, 
    ProductStandardAmt DECIMAL(10,2) NULL,

    CONSTRAINT FK_OrderDetail_Sale 
        FOREIGN KEY (SalesOrderNumber, SalesOrderLineNumber)
        REFERENCES stg.stg_Sale(SalesOrderNumber, SalesOrderLineNumber),

    CONSTRAINT FK_OrderDetail_Product 
        FOREIGN KEY (ProductKey)
        REFERENCES stg.stg_Product(ProductKey)
);
GO

-- DATABASE STATISTICS TABLE ---------------------------------------------------------------------------
IF OBJECT_ID('stg.dbStatistics', 'U') IS NOT NULL
    DROP TABLE stg.dbStatistics;
GO

CREATE TABLE stg.dbStatistics (
    StatId INT IDENTITY(1,1) PRIMARY KEY,
    TableName NVARCHAR(128) NOT NULL,
    SchemaName NVARCHAR(128) NOT NULL,
    RecordCount BIGINT NOT NULL,
    SpaceUsedKB DECIMAL(18,2) NOT NULL,
    StatisticsDateTime DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO
