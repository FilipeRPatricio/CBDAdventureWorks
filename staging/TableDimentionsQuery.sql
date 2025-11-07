/*
Grupo 5
202300133, Filipe Rodrigues Patricio
202300532, José Vicente Camolas da Silva
Queries para obter as dimensões das tabelas 
*/

USE AdventureWorksLegacy;
GO

SELECT 
    s.name AS SchemaName,
    t.name AS TableName,
    SUM(p.rows) AS NumbReg,
    SUM(a.total_pages) * 8 AS DimTabKb,
    CASE WHEN SUM(p.rows) = 0 THEN 0
         ELSE ROUND((SUM(a.total_pages) * 8.0) / SUM(p.rows), 4)
    END AS AvgKBPerRow
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.indexes i ON t.object_id = i.object_id
JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.is_ms_shipped = 0
GROUP BY s.name, t.name
ORDER BY DimTabKb DESC;
GO

