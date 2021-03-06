USE [dbaadmin]
GO
/****** Object:  StoredProcedure [dbo].[dbasp_Logship_MS_Fix]    Script Date: 04/02/2013 10:27:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--CREATE PROCEDURE [dbo].[dbasp_RestoreAll]
--	(
DECLARE	@DBName		SYSNAME		= 'RunBook'
	,@NewDBName	SYSNAME		= 'RunBook_Test'
	,@Recover	BIT		= 1
	,@Full		BIT		= 1
	,@Diff		BIT		= 1
	,@Tran		BIT		= 1
	,@File		BIT		= 0
	,@RestorePath	VARCHAR(MAX)	= NULL
	,@LogPath	VarChar(MAX)	= NULL
	,@DataPath	VarChar(MAX)	= NULL
	,@DevOverides	VarChar(MAX)	= NULL -- USE KEYWORD "KEEP" OR NAMED PAIRS OF {LogicalName}={PhysicalPathName},{LogicalName}={PhysicalPathName},... FOR EVERY DEVICE
	,@CleanFolder	BIT		= 0
	,@ScriptOnly	BIT		= 0
--	)
--AS
	/*

		-- ============================================================================================================
		-- Revision History
		-- Date		Author     				                     Desc
		-- ==========	====================	=======================================================================
		-- 04/24/2013	Steve Ledridge		Created Procedure

	*/


	SET NOCOUNT ON
	SET ANSI_WARNINGS OFF


	DECLARE		@MostRecent_Full	DATETIME
			,@MostRecent_Diff	DATETIME
			,@MostRecent_Log	DATETIME
			,@CMD			VARCHAR(8000)
			,@CMD2			VARCHAR(8000)
			,@CnD_CMD		VARCHAR(8000)
			,@COPY_CMD		VARCHAR(max)
			,@BackupPath		VARCHAR(max)
			,@FileName		VARCHAR(MAX)
			,@AgentJob		SYSNAME
			,@ShareName		VarChar(500)
			,@errorcode		INT
			,@sqlerrorcode		INT
			,@DateModified		DATETIME
			,@Extension		VARCHAR(MAX)
			,@CopyStartTime		DateTime
			,@partial_flag		BIT
			,@RestoreOrder		INT

	DECLARE		@SourceFiles		TABLE 
			(
			[Mask]			[nvarchar](4000) NULL,
			[Name]			[nvarchar](4000) NULL,
			[FullPathName]		[nvarchar](4000) NULL,
			[Directory]		[nvarchar](4000) NULL,
			[Extension]		[nvarchar](4000) NULL,
			[DateCreated]		[datetime] NULL,
			[DateAccessed]		[datetime] NULL,
			[DateModified]		[datetime] NULL,
			[Attributes]		[nvarchar](4000) NULL,
			[Size]			[bigint] NULL
			)
			
	DECLARE		@nameMatches		TABLE (NAME VARCHAR(MAX))		
	DECLARE		@CopyAndDeletes		TABLE (CnD_CMD VarChar(max))
	
	DECLARE		@DBSources		TABLE
			(
			DBName			SYSNAME
			,BackupPath		VARCHAR(8000)
			,AgentJob		VarChar(8000)
			)

	IF OBJECT_ID('tempdb..#filelist')	IS NOT NULL	DROP TABLE #filelist		
	CREATE TABLE #filelist		(
					LogicalName NVARCHAR(128) NULL, 
					PhysicalName NVARCHAR(260) NULL, 
					type CHAR(1), 
					FileGroupName NVARCHAR(128) NULL, 
					SIZE NUMERIC(20,0), 
					MaxSize NUMERIC(20,0),
					FileId BIGINT,
					CreateLSN NUMERIC(25,0),
					DropLSN NUMERIC(25,0),
					UniqueId VARCHAR(50),
					ReadOnlyLSN NUMERIC(25,0),
					ReadWriteLSN NUMERIC(25,0),
					BackupSizeInBytes BIGINT,
					SourceBlockSize INT,
					FileGroupId INT,
					LogGroupGUID VARCHAR(50) NULL,
					DifferentialBaseLSN NUMERIC(25,0),
					DifferentialBaseGUID VARCHAR(50),
					IsReadOnly BIT,
					IsPresent BIT,
					TDEThumbprint VARBINARY(32) NULL,
					New_PhysicalName  NVARCHAR(1000) NULL
					)

	SELECT		@RestorePath	= COALESCE(@RestorePath,'\\'+ LEFT(@@ServerName,CHARINDEX('\',@@ServerName+'\')-1)+'\'+REPLACE(@@ServerName,'\','$')+'_backup')

	IF @Full = 1			
		INSERT INTO @nameMatches(NAME)
		VALUES  (@DBName+'_db_20%')
	
	IF @File = 1			
		INSERT INTO @nameMatches(NAME)
		VALUES  (@DBName+'_db_FG_20%')
	
	IF @Diff = 1			
		INSERT INTO @nameMatches(NAME)
		VALUES  (@DBName+'_dfntl_20%')

	IF @Tran = 1			
		INSERT INTO @nameMatches(NAME)
		VALUES  (@DBName+'_tlog_20%')

	--SELECT * FROM @nameMatches

	DELETE		@SourceFiles
	
	INSERT INTO	@SourceFiles
	SELECT		DISTINCT
			T2.Name
			,T1.*
	FROM		dbaadmin.dbo.dbaudf_DirectoryList2(@RestorePath,NULL,0) T1
	JOIN		@nameMatches T2
		ON	T1.NAME LIKE T2.NAME

	--SELECT @RestorePath
	--SELECT * FROM @SourceFiles

	DELETE		T1
	FROM		@SourceFiles T1
	LEFT JOIN	(
			SELECT	MASK,EXTENSION,MAX(DateModified)DateModified
			FROM	@SourceFiles
			GROUP BY MASK,EXTENSION
			) T2
		ON	T1.Mask = T2.Mask
		AND	T1.Extension = T2.Extension
		AND	T1.DateModified = T2.DateModified
	WHERE		T1.Extension NOT IN ('.cTRN','.TRN','.sqt')
		AND	T2.Mask IS NULL	


	DELETE		T1
	FROM		@SourceFiles T1
	WHERE		Extension IN ('.cTRN','.TRN','.sqt')
		AND	DateModified <= (
						SELECT	MAX(DateModified)DateModified
						FROM	@SourceFiles
						WHERE	Extension NOT IN ('.cTRN','.TRN','.sqt')
						)


	--SELECT * FROM @SourceFiles


	;WITH		SourceFiles
			AS
			(
			SELECT		*
			FROM		@SourceFiles
			)
			,QueuedFiles
			AS
			(
			SELECT		DISTINCT T1.*
			FROM		dbaadmin.dbo.dbaudf_DirectoryList2(@RestorePath,null,0) T1
			JOIN		@nameMatches T2
				ON	T1.NAME LIKE T2.NAME
			)
			,AppliedFiles
			AS
			(
			SELECT		DISTINCT
					REPLACE([physical_device_name],@RestorePath+'\','') AS [name]
					,[physical_device_name] AS [Path]
			FROM		[msdb].[dbo].[backupset] bs
			JOIN		[msdb].[dbo].[backupmediafamily] bmf
				ON	bmf.[media_set_id] = bs.[media_set_id]
			WHERE		bs.database_name = COALESCE(@NewDBName,@DBName)
			)
			,Files
			AS
			(
			SELECT		Q.Name
					,Q.FullPathName
					,Q.DateModified
					,CASE	WHEN S.Name IS NULL THEN 'X'
						WHEN S.NAME IS NOT NULL AND A.Name IS NULL THEN 'Q'
						WHEN S.NAME IS NOT NULL AND A.NAME IS NOT NULL THEN 'A'
						ELSE '?'
						END AS [Status]

			FROM		QueuedFiles Q
			LEFT JOIN	SourceFiles S 
				ON	Q.name = S.Name
			LEFT JOIN	AppliedFiles A 
				ON	A.name = S.Name
			)
			
	INSERT INTO	@CopyAndDeletes
	SELECT		CASE [Status]
				WHEN 'X'	THEN 'DEL ' + fullpathname
				ELSE '|' + fullpathname + ' is Good.'
				END
	FROM		Files F 
	ORDER BY	[Status],[DateModified]

	IF @CleanFolder = 1
	BEGIN
		RAISERROR('  -- Starting Delete''s',-1,-1) WITH NOWAIT

		DECLARE CopyAndDeleteCursor CURSOR
		FOR
		SELECT CnD_CMD FROM @CopyAndDeletes

		OPEN CopyAndDeleteCursor
		FETCH NEXT FROM CopyAndDeleteCursor INTO @CnD_CMD
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN
				SET @CMD = REPLACE (@CnD_CMD,'|','  ')
				RAISERROR('    -- %s',-1,-1,@CMD) WITH NOWAIT

				IF @ScriptOnly = 0 AND LEFT(@CnD_CMD,1) != '|'
					exec xp_CmdShell @CnD_CMD,no_output 
			END
			FETCH NEXT FROM CopyAndDeleteCursor INTO @CnD_CMD
		END

		CLOSE CopyAndDeleteCursor
		DEALLOCATE CopyAndDeleteCursor
		
		RAISERROR('  -- Done with Delete''s',-1,-1) WITH NOWAIT
	END

		
	-- GET LOG PATH
	If	nullif(@LogPath,'') IS NULL
	  OR	dbaadmin.dbo.dbaudf_GetFileProperty(@LogPath,'Folder','Exists') != 'True'
	BEGIN
		SET	@ShareName	= REPLACE(@@ServerName,'\','$')+'_ldf'			
		exec	dbaadmin.dbo.dbasp_get_share_path @ShareName,@LogPath OUT
	END

	-- GET DATA PATH
	If	nullif(@DataPath,'') IS NULL
	  OR	dbaadmin.dbo.dbaudf_GetFileProperty(@DataPath,'Folder','Exists') != 'True'
	BEGIN
		SET	@ShareName	= REPLACE(@@ServerName,'\','$')+'_mdf'			
		exec	dbaadmin.dbo.dbasp_get_share_path @ShareName,@DataPath OUT
	END

	RAISERROR('  -- Starting DB Restore''s',-1,-1) WITH NOWAIT
	DECLARE RestoreDBCursor CURSOR
	FOR
	SELECT		DISTINCT
			CASE WHEN T1.Extension IN('.cTRN','.TRN','.sqt') THEN 3
				WHEN T1.Extension IN('.cDIF','.SQD') THEN 2 ELSE 1 END [RestoreOrder]
			,T1.[DateModified]
			,T1.[fullpathname]
			,T1.[Extension]
	FROM		@SourceFiles T1
	LEFT JOIN	(		
			SELECT		DISTINCT
					dbaadmin.dbo.dbaudf_GetFileFromPath([physical_device_name]) AS [name]
					,[physical_device_name] AS [Path]
			FROM		[msdb].[dbo].[backupset] bs
			JOIN		[msdb].[dbo].[backupmediafamily] bmf
				ON	bmf.[media_set_id] = bs.[media_set_id]
			JOIN		msdb.dbo.restorehistory rh
				ON	rh.backup_set_id = bs.backup_set_id
				AND	rh.destination_database_name = bs.database_name
			WHERE		bs.database_name = COALESCE(@NewDBName,@DBName)
			) T3		
		ON	T3.[name] = T1.[Name]
		
	WHERE		T3.[Name] IS NULL
		AND	(
			Extension IN('.cTRN','.TRN','.sqt') 
		OR	(DB_ID(COALESCE(@NewDBName,@DBName)) IS NULL AND Extension IN('.cDIF','.SQD','.cBAK','.sqb'))
			)
	ORDER BY	1,2


	OPEN RestoreDBCursor
	FETCH NEXT FROM RestoreDBCursor INTO @RestoreOrder,@DateModified,@FileName, @Extension
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
		
			-- GET FILE HEADER INFO FROM THE BACKUP FILE
			DELETE FROM #filelist
			
			IF	-- REDGATE FILE
			@Extension IN ('.sqb','.sqd','.sqt')
			BEGIN
				SELECT @CMD2 = 'Exec master.dbo.sqlbackup ''-SQL "RESTORE FILELISTONLY FROM DISK = ''''' + @FileName + '''''"'''
				PRINT '   -- ' + @CMD2
				INSERT INTO #filelist (LogicalName,PhysicalName,type, FileGroupName, SIZE,MaxSize,FileId,CreateLSN,DropLSN,UniqueId,ReadOnlyLSN,ReadWriteLSN,BackupSizeInBytes,SourceBlockSize,FileGroupId,LogGroupGUID,DifferentialBaseLSN,DifferentialBaseGUID,IsReadOnly,IsPresent)
				EXEC (@CMD2)
			END
			ELSE
			BEGIN	
				SELECT @CMD2 = 'RESTORE FILELISTONLY FROM DISK = ''' + @FileName + ''''
				PRINT '   -- ' + @CMD2
				IF (SELECT @@version) NOT LIKE '%Server 2005%' AND (SELECT SERVERPROPERTY ('productversion')) > '10.00.0000' --sql2008 or higher
					INSERT INTO #filelist (LogicalName,PhysicalName,type,FileGroupName,SIZE,MaxSize,FileId,CreateLSN,DropLSN,UniqueId,ReadOnlyLSN,ReadWriteLSN,BackupSizeInBytes,SourceBlockSize,FileGroupId,LogGroupGUID,DifferentialBaseLSN,DifferentialBaseGUID,IsReadOnly,IsPresent,TDEThumbprint)
					EXEC (@CMD2)
				ELSE
					INSERT INTO #filelist (LogicalName,PhysicalName,type,FileGroupName,SIZE,MaxSize,FileId,CreateLSN,DropLSN,UniqueId,ReadOnlyLSN,ReadWriteLSN,BackupSizeInBytes,SourceBlockSize,FileGroupId,LogGroupGUID,DifferentialBaseLSN,DifferentialBaseGUID,IsReadOnly,IsPresent)
					EXEC (@CMD2)
			END

			IF (SELECT COUNT(*) FROM #filelist) = 0
				RAISERROR('DBA Error: Unable to process FILELISTONLY for file %s.',16,1,@FileName)
				
			UPDATE		T1
				SET	NEW_PhysicalName 
				    =	COALESCE	(
							CASE @DevOverides WHEN 'KEEP' THEN PhysicalName END
							,T2.detail03 -- USE LOCAL_CONTROL OVERRIED IF IT EXISTS
							,CASE T1.TYPE WHEN 'D' THEN @DataPath ELSE @LogPath END + '\' + dbaadmin.dbo.dbaudf_GetFileFromPath(PhysicalName)
							)
			FROM		#filelist T1
			LEFT JOIN	dbo.local_control T2
				ON	T2.subject = 'restore_override' 
				AND	T2.detail01 = @DBName 
				AND	T2.detail02 = T1.LogicalName
				
			--SELECT 	* FROM #filelist


			-- IF FORECED DEVICE OVERIDES ARE PASSED IN AND VALID, USE THEM.			
			IF NULLIF(@DevOverides,'KEEP') IS NOT NULL
				UPDATE		T1
					SET	NEW_PhysicalName = T2.Value
				FROM		#filelist T1
				JOIN		dbaadmin.dbo.dbaudf_StringToTable_Pairs(@DevOverides,',','=') T2
					ON	T2.Label = T1.LogicalName			
				WHERE		dbaadmin.dbo.dbaudf_GetFileProperty(REPLACE(T2.Value,dbaadmin.dbo.dbaudf_GetFileFromPath(T2.Value),''),'folder','Exists') = 'True'

			
			
			IF EXISTS (SELECT * FROM #filelist WHERE isPresent = 0) AND EXISTS (SELECT * FROM #filelist WHERE isPresent = 1 AND FileGroupId = 1)
				SET @Partial_flag = 1
			ELSE	
				SET @Partial_flag = 0					
		
			IF	-- FULL OR DIFF BACKUP FILE
			@Extension IN ('.cBAK','.cDIF','.sqd','.sqb')
			BEGIN
				SET @CMD = 'RESTORE DATABASE ['+ COALESCE(@NewDBName,@DBName) + '] '
				
				IF @Partial_flag = 1
					SELECT	@CMD = @CMD + dbaadmin.dbo.dbaudf_ConcatenateUnique('FILEGROUP = '''+FileGroupName+'''')
					FROM	#filelist
					WHERE	isPresent = 1

				
				SET @CMD = @CMD + CHAR(13)+ CHAR(10)+'FROM    DISK = '''+@FileName+''''+ CHAR(13)+CHAR(10)
				
				SET @CMD	= @CMD 
						+ 'WITH    ' + CASE @partial_flag WHEN 1 THEN 'PARTIAL, ' ELSE '' END
						+ 'NORECOVERY, REPLACE' + CHAR(13)+CHAR(10)

				SELECT		@CMD = @CMD
						+ '        ,MOVE ''' + LogicalName + ''' TO ''' + NEW_PhysicalName + '''' + CHAR(13) + CHAR(10)
				FROM		#filelist						
				ORDER BY	FileID

				IF	-- REDGATE SYNTAX
				@Extension IN ('.sqd','.sqb')
				BEGIN
					SET @CMD = 'Exec master.dbo.sqlbackup ''-SQL "' + REPLACE(
											  REPLACE(
											  REPLACE(
											  REPLACE(
											  REPLACE(@CMD,CHAR(9),' ')
												      ,CHAR(13)+CHAR(10),' ')
												      ,'''','''''') 
												      ,'  ',' ')
												      ,'  ',' ')
												     +'"'''
				
				
					PRINT '   -- ' + REPLACE(@CMD,CHAR(13)+CHAR(10),CHAR(13)+CHAR(10)+'   -- ')
					RAISERROR('',-1,-1) WITH NOWAIT
					
					IF @ScriptOnly = 0
						EXEC (@CMD)
				END
				ELSE	-- MICROSOFT SYNTAX
				BEGIN
					SET @CMD = @CMD + '        ,STATS' + CHAR(13) + CHAR(10)

					PRINT '   -- ' + REPLACE(@CMD,CHAR(13)+CHAR(10),CHAR(13)+CHAR(10)+'   -- ')
					RAISERROR('',-1,-1) WITH NOWAIT
					
					IF @ScriptOnly = 0
						EXEC(@CMD)
				END
			
			END

		
			IF	-- TRANSACTION LOG BACKUP FILE
			@Extension IN('.cTRN','.TRN','.sqt')
			BEGIN
				SET @CMD = 'RESTORE LOG ['+COALESCE(@NewDBName,@DBName)+'] FROM DISK ='''+@FileName+''' WITH NORECOVERY'

				IF	-- REDGATE SYNTAX
				@Extension = '.sqt'
				BEGIN
					SET @CMD = '-SQL "'+@CMD+'"'
					PRINT '   -- ' + REPLACE(@CMD,CHAR(13)+CHAR(10),CHAR(13)+CHAR(10)+'   -- ')
					RAISERROR('',-1,-1) WITH NOWAIT
					
					IF @ScriptOnly = 0
					BEGIN
						EXECUTE master..sqlbackup @CMD, @errorcode OUT, @sqlerrorcode OUT;
						IF (@errorcode >= 500) OR (@sqlerrorcode <> 0)
							RAISERROR ('Redgate Restore on %s failed with exit code: %d  SQL error code: %d', 16, 1, @DBName, @errorcode, @sqlerrorcode)
					END
				END
				ELSE	-- MICROSOFT SYNTAX
				BEGIN
					PRINT '   -- ' + REPLACE(@CMD,CHAR(13)+CHAR(10),CHAR(13)+CHAR(10)+'   -- ')
					RAISERROR('',-1,-1) WITH NOWAIT
					
					IF @ScriptOnly = 0
						EXEC(@CMD)
				END
			END
			RAISERROR('',-1,-1) WITH NOWAIT
			
		END
		FETCH NEXT FROM RestoreDBCursor INTO @RestoreOrder,@DateModified,@FileName, @Extension
	END

	CLOSE RestoreDBCursor
	DEALLOCATE RestoreDBCursor

	IF @Recover = 1
	BEGIN
		SET @CMD = 'RESTORE DATABASE ['+COALESCE(@NewDBName,@DBName)+'] WITH RECOVERY'
		
		PRINT '   -- ' + REPLACE(@CMD,CHAR(13)+CHAR(10),CHAR(13)+CHAR(10)+'   -- ')
		RAISERROR('',-1,-1) WITH NOWAIT
					
		IF @ScriptOnly = 0
			EXEC(@CMD)
	
	END
	
	RAISERROR('  -- Done with DB Restore''s',-1,-1) WITH NOWAIT
	

GO
