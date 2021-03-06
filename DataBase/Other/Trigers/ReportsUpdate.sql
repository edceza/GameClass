USE [GameClass]
GO
/****** Объект:  Trigger [dbo].[ReportsUpdate]    Дата сценария: 01/22/2013 19:00:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/* ----------------------------------------------------------------------------- 
Обновление триггера для дерева отчетов 
----------------------------------------------------------------------------- */ 
CREATE TRIGGER [dbo].[ReportsUpdate] ON [dbo].[Reports] 
FOR INSERT, UPDATE, DELETE 
AS 
BEGIN 
DECLARE @id int 
DECLARE @Code varchar(8000) 
DECLARE @ProcName varchar(100) 
DECLARE @idParent int 
DECLARE @Invariable int 
DECLARE Dcursor CURSOR FOR SELECT DISTINCT [id]  
FROM  
(SELECT [id] FROM DELETED WHERE dbo.IsSpecialReport([id]) = 1 
UNION ALL  
SELECT [id] FROM INSERTED WHERE dbo.IsSpecialReport([id]) = 1) IDTable 
OPEN Dcursor 
FETCH NEXT FROM Dcursor INTO @id 
WHILE @@FETCH_STATUS = 0 
BEGIN 
SET @ProcName = 'CustomReport' + CONVERT(varchar(5),@id) + 'Execute' 
SET @Code = 'if exists (select * from dbo.sysobjects where id = object_id(N''[dbo].[' 
SET @Code = @Code + @ProcName + ']'') and OBJECTPROPERTY(id, N''IsProcedure'') = 1)' 
SET @Code = @Code + 'drop procedure [dbo].[' + @ProcName + ']' 
EXEC (@Code) 
FETCH NEXT FROM Dcursor INTO @id 
END 
CLOSE Dcursor 
DEALLOCATE Dcursor 
DECLARE Icursor CURSOR FOR SELECT [id] FROM INSERTED WHERE dbo.IsSpecialReport([id]) = 1 
OPEN Icursor 
FETCH NEXT FROM Icursor INTO @id 
WHILE @@FETCH_STATUS = 0 
BEGIN 
SELECT @Code = CONVERT(varchar(8000),[Code]), @idParent = ParentID, @Invariable = Invariable FROM Reports WHERE [id] = @id 
IF LEN(@Code) > 0  
BEGIN 
SET @Code = REPLACE(@Code, '%TIME-CURRENT%', '@Current') 
SET @Code = REPLACE(@Code, '%TIME-START%', '@Begin') 
SET @Code = REPLACE(@Code, '%TIME-STOP%', '@End') 
SET @Code = REPLACE(@Code, '%SHIFT-BEGIN%', '@CurrentShiftBegin') 
SET @Code = REPLACE(@Code, '%SHIFT2-BEGIN%', '@PrevShiftBegin') 
SET @Code = REPLACE(@Code, '%SHIFT2-END%', '@PrevShiftEnd') 
SET @ProcName = 'CustomReport' + CONVERT(varchar(5),@id) + 'Execute' 
SET @Code = 'CREATE PROCEDURE ' + @ProcName + ' 
@Current datetime, 
@Begin datetime, 
@End datetime, 
@CurrentShiftBegin datetime, 
@PrevShiftBegin datetime, 
@PrevShiftEnd datetime 
AS 
SET NOCOUNT ON 
' + CASE WHEN @Invariable <> 1 THEN 'IF dbo.GetCustomReportParentId() = ' + CONVERT(varchar(5),@idParent) ELSE ' ' END + ' 
BEGIN 
' + @Code + ' 
END 
' 
EXEC (@Code) 
SET @Code = 'GRANT EXEC ON [' + @ProcName + '] TO public' 
EXEC (@Code) 
END 
FETCH NEXT FROM Icursor INTO @id 
END 
CLOSE Icursor 
DEALLOCATE Icursor 
END 
