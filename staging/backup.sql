-- Atualmente é mostrado que nao tenho as permissoes necessarias para fazer o backup ao correr o código, consultar o professor para saber o que fazer em concreto


-- Modelo de Recuperação: FULL

-- Garantir modelo de recuperação FULL
ALTER DATABASE AdventureWorksLegacy
SET RECOVERY FULL;
GO


-- Backup Completo

BACKUP DATABASE AdventureWorksLegacy
TO DISK = 'C:\Users\filip\CBDBackups\full.bak'
WITH INIT,
     NAME = 'AdventureWorksLegacy Full Backup',
     STATS = 10;
GO


-- Backup Diferencial

BACKUP DATABASE AdventureWorksLegacy
TO DISK = 'C:\Users\filip\CBDBackups\differential.bak'
WITH DIFFERENTIAL,
     INIT,
     NAME = 'AdventureWorksLegacy Differential Backup',
     STATS = 10;
GO


-- Backup de Logs

BACKUP LOG AdventureWorksLegacy
TO DISK = 'C:\Users\filip\CBDBackups\log1.trn'
WITH INIT,
     NAME = 'AdventureWorksLegacy Log Backup 01',
     STATS = 10;
GO

-- cadeia de logs
BACKUP LOG AdventureWorksLegacy
TO DISK = 'C:\Users\filip\CBDBackups\log2.trn'
WITH INIT,
     NAME = 'AdventureWorksLegacy Log Backup 02',
     STATS = 10;
GO


