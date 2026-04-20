-- -----------------------------------------------------------------------------
-- Backup Completo do Banco de Dados
-- -----------------------------------------------------------------------------
BACKUP DATABASE IFEats
-- ATENÇÃO: Altere o caminho abaixo para um diretório existente em sua máquina
TO DISK = 'C:\SEU_CAMINHO\IFEats-FullBackup.bak'
GO
PRINT 'Backup do banco de dados IFEats concluído com sucesso em C:\Temp\IFEats_FullBackup.bak';
GO

-- Restaurando o Banco IFeats
USE master;
GO
ALTER DATABASE IFEats SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE IFEats;
GO
RESTORE DATABASE IFEats
FROM DISK = 'C:\SEU_CAMINHO\IFEats-FullBackup.bak'
GO
USE IFEats;
GO
PRINT 'Banco de dados IFEat restaurado com sucesso';