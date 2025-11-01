--criação da stg schema e criação das tabelas staging

USE AdventureWorksLegacy;
GO

--criar schema se ainda não existir
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'stg')
    EXEC('CREATE SCHEMA stg;');
GO

--se a tabela já existir, elimina-a 
IF OBJECT_ID('stg.stg_Currency', 'U') IS NOT NULL
    DROP TABLE stg.stg_Currency;
GO


CREATE TABLE stg.stg_Currency (
    CurrencyKey INT IDENTITY(1,1) PRIMARY KEY,
    CurrencyAlternateKey NVARCHAR(50) UNIQUE,
    CurrencyName NVARCHAR(50)
);
GO
