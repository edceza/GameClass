USE GameClass
GO

/* -----------------------------------------------------------------------------
                               ������ ����� � �������� � ReportCurrent
----------------------------------------------------------------------------- */

GRANT  EXECUTE  ON [dbo].[ReportCurrent]  TO [public]
GO


/* -----------------------------------------------------------------------------
                               ������ AutoUpdate
----------------------------------------------------------------------------- */


DELETE FROM [GameClass].[dbo].[AutoUpdate] WHERE 1=1;
GO

/* -----------------------------------------------------------------------------
	           ���������� ����� �� ��������� �����
----------------------------------------------------------------------------- */


IF NOT EXISTS (SELECT * FROM [dbo].[functions] WHERE [id] = 37)
BEGIN
	INSERT INTO [functions]([id],[name]) VALUES(37,N'fnCompBackPartMoney')

	INSERT INTO [functionsrights]([idFunctions],[idUsersGroup]) VALUES(37,1)
	INSERT INTO [functionsrights]([idFunctions],[idUsersGroup]) VALUES(37,2)
	INSERT INTO [functionsrights]([idFunctions],[idUsersGroup]) VALUES(37,3)
END
GO





/* -----------------------------------------------------------------------------
                               UPDATE Version
---------------------------------------------------------------------------- */
UPDATE Registry SET [value]='3.85.6' WHERE [key]='BaseVersion'
GO


