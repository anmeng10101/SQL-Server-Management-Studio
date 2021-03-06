
CREATE TABLE	#Tables	(DBName sysname, TableName sysname, ColumnName sysname)

exec sp_msforeachdb
'USE [?]; INSERT INTO #Tables
SELECT	''?'',object_name(id),name
FROM	syscolumns
WHERE	name IN (''DBName'',''database'',''db_name'',''dbid'',''DfltDB'',''DatabaseName'',''component_name'')
	AND Objectpropertyex(id,''IsMSShipped'') = 0
	AND Objectpropertyex(id,''IsSystemTable'') = 0
	AND Objectpropertyex(id,''IsTable'') = 1'

SELECT	DISTINCT '	PRINT	''  Checking Table ['+[TableName]+']''

	SELECT	@Params	= ''@BackupDB SYSNAME, @RestoreDB SYSNAME''
			,@TSQL	= ''USE '' + @CheckDB +CHAR(13)+CHAR(10)
					+ ''IF OBJECT_ID(''''['+[TableName]+']'''') IS NOT NULL
	 IF EXISTS (SELECT * FROM ['+[TableName]+'] WHERE ['+[ColumnName]+'] = @BackupDB)
	  IF NOT EXISTS (SELECT * FROM ['+[TableName]+'] WHERE ['+[ColumnName]+'] = @RestoreDB)
		BEGIN
			PRINT	''''    Cloning Table ['+[TableName]+']''''

			SELECT		* 
				INTO	[#'+[TableName]+'] 
			FROM		['+[TableName]+'] 
			WHERE		['+[ColumnName]+'] = @BackupDB;
			
			UPDATE		[#'+[TableName]+'] 
				SET		['+[ColumnName]+'] = @RestoreDB;
			
			INSERT INTO	['+[TableName]+'] 
			SELECT		* 
			FROM		[#'+[TableName]+'];
			
			DROP TABLE	[#'+[TableName]+'];
		END''
		
	EXEC sp_executesql @TSQL,@Params,@BackupDB,@RestoreDB'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)

--SELECT	*
FROM	#Tables
WHERE	DBName IN ('deplinfo','deplcontrol','gears')
	AND	TableName IN
(
'Appl_Dependencies'
,'ControlTable'
,'DataSync_target_table'
,'db_BaseLocation'
,'db_sequence'
,'DEPL_Dependencies'
,'PostRestoreDataUpdate'
,'Search'
,'db_ApplCrossRef'
,'PostRestoreDataUpdate'
,'COMPONENTS'
)
	
	
ORDER BY	1

DROP TABLE	#Tables	

