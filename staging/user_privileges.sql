/*
Grupo 5
202300133, Filipe Rodrigues Patricio
202300532, José Vicente Camolas da Silva

Criação de roles e atribuição de privilégios
*/

USE AdventureWorksLegacy;
GO

CREATE ROLE Admin;
GRANT CONTROL ON DATABASE::AdventureWorksLegacy TO Admin;
GO

CREATE ROLE SalesPerson;
GRANT SELECT, INSERT, UPDATE, DELETE ON stg.stg_Sale TO SalesPerson;
GRANT SELECT, INSERT, UPDATE, DELETE ON stg.stg_OrderDetail TO SalesPerson;

GRANT SELECT ON stg.stg_Country TO SalesPerson;
GRANT SELECT ON stg.stg_SalesTerritoryGroup TO SalesPerson;
GRANT SELECT ON stg.stg_City TO SalesPerson;
GRANT SELECT ON stg.stg_Customer TO SalesPerson;
GRANT SELECT ON stg.stg_User TO SalesPerson;
GRANT SELECT ON stg.stg_SentEmails TO SalesPerson;
GRANT SELECT ON stg.stg_Phone TO SalesPerson;
GRANT SELECT ON stg.stg_Province TO SalesPerson;
GRANT SELECT ON stg.stg_Currency TO SalesPerson;
GRANT SELECT ON stg.stg_ProductSubCategory TO SalesPerson;
GRANT SELECT ON stg.stg_Manufacturer TO SalesPerson;
GRANT SELECT ON stg.stg_Product TO SalesPerson;
GRANT SELECT ON stg.stg_SalesTerritory TO SalesPerson;
GO

-- View para o "Rocky Mountain"
CREATE VIEW stg.vw_RockyMountainSales
AS
SELECT
    s.*,
    st.SalesTerritoryRegion
FROM stg.stg_Sale s
JOIN stg.stg_Customer c ON s.CustomerKey = c.CustomerKey
JOIN stg.stg_SalesTerritory st ON c.SalesTerritoryKey = st.SalesTerritoryKey
WHERE st.SalesTerritoryRegion = 'Rocky Mountain';
GO

CREATE ROLE SalesTerritory;
GRANT SELECT ON stg.vw_RockyMountainSales TO SalesTerritory;
GO


-- Admin
CREATE LOGIN admin_user WITH PASSWORD = 'complex_password_123!';
CREATE USER admin_user FOR LOGIN admin_user;
ALTER ROLE Admin ADD MEMBER admin_user;
GO

-- SalesPerson
CREATE LOGIN salesperson_user WITH PASSWORD = 'complex_password_456!';
CREATE USER salesperson_user FOR LOGIN salesperson_user;
ALTER ROLE SalesPerson ADD MEMBER salesperson_user;
GO

-- SalesTerritory
CREATE LOGIN salesterritory_user WITH PASSWORD = 'complex_password_789!';
CREATE USER salesterritory_user FOR LOGIN salesterritory_user;
ALTER ROLE SalesTerritory ADD MEMBER salesterritory_user;
GO