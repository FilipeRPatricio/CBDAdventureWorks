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

-- PRODUCT SUB CATEGORY --------------------------------TOU A TER PROBLEMAS AQUI ------------
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



-- SELECT * FROM stg.stg_ProductSubCategory;



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

-- SELECT * FROM stg.stg_Product;

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

-- SELECT TOP 10 * FROM stg.stg_Manufacturer;


-- SALES TERRITORY GROUP ---------------------------------------------------------------------------

INSERT INTO stg.stg_SalesTerritoryGroup (
    GroupName
    )
    SELECT DISTINCT
        s.GroupName
    FROM stg.stg_SalesTerritoryGroup AS s

    SELECT TOP 10 * FROM stg.stg_SalesTerritoryGroup;

