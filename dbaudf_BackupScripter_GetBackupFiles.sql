USE [DBAAdmin]
GO
/****** Object:  UserDefinedFunction [dbo].[dbaudf_BackupScripter_GetBackupFiles]    Script Date: 11/19/2014 12:33:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION		[dbo].[dbaudf_BackupScripter_GetBackupFiles]
				(
				@DBName			SYSNAME
				,@FilePath		VarChar(max)
				,@IncludeSubDir		bit		= 0
				,@ForceFileName		VarChar(max)	= null
				)
RETURNS TABLE AS RETURN
(
	SELECT		dbaadmin.dbo.dbaudf_RegexReplace(T1.Name,'_SET_[0-9][0-9]_OF_[0-9][0-9]','_SET_[0-9][0-9]_OF_[0-9][0-9]') [Mask]
			,T1.Name
			,@DBName [DBName]
			,	CAST(STUFF(STUFF(STUFF(STUFF(STUFF((
				SELECT	TOP 1 SUBSTRING(Text,2,14)
				FROM	dbaadmin.dbo.dbaudf_RegexMatches(T1.Name,'_20[0-9][0-9][0-1][0-9][0-3][0-9][0-2][0-9][0-5][0-9][0-5][0-9][._]')
				),13,0,':'),11,0,':'),9,0,' '),7,0,'-'),5,0,'-') AS DATETIME) [BackupTimeStamp]
			,T2.BackupType
			,CASE T1.Extension 
				WHEN '.sqb' THEN 'RedGate'
				WHEN '.sqd' THEN 'RedGate'
				WHEN '.sqt' THEN 'RedGate'
				ELSE 'Microsoft' END [BackupEngine]
			,	ISNULL((
				SELECT	TOP 1 CAST(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(Text,'_','|'),2) AS INT)
				FROM	dbaadmin.dbo.dbaudf_RegexMatches(T1.Name,'SET_[0-9][0-9]_OF_[0-9][0-9]')
				),1) [BackupSetNumber]				
			,	ISNULL((
				SELECT	TOP 1 CAST(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(Text,'_','|'),4) AS INT)
				FROM	dbaadmin.dbo.dbaudf_RegexMatches(T1.Name,'SET_[0-9][0-9]_OF_[0-9][0-9]')
				),1) [BackupSetSize]

			,CASE WHEN T1.Name LIKE @DBName+'_DB_FG_%' 
				THEN	(
					SELECT	REPLACE(REPLACE([dbaadmin].[dbo].[dbaudf_Concatenate]([SplitValue]),',','_'),'FG$','')
					FROM	(
						SELECT	*
						FROM	[dbaadmin].[dbo].[dbaudf_StringToTable](REPLACE(REPLACE(REPLACE(REPLACE(T1.Name,'_DB_FG_','_FG$'),'_','|'),'.','|'),REPLACE(@DBName,'_','|'),@DBName),'|')
						) D
					WHERE	OccurenceID > 1 
						AND	OccurenceID < (SELECT max(OccurenceID) FROM [dbaadmin].[dbo].[dbaudf_StringToTable](REPLACE(REPLACE(REPLACE(REPLACE(dbaadmin.dbo.dbaudf_RegexReplace(T1.Name,'_SET_[0-9][0-9]_OF_[0-9][0-9]',''),'_DB_FG_','_FG$'),'_','|'),'.','|'),REPLACE(@DBName,'_','|'),@DBName),'|')) - 1
					)
				END [FileGroup]
			,T1.FullPathName	
			,T1.Directory	
			,T1.Extension	
			,T1.DateCreated	
			,T1.DateAccessed	
			,T1.DateModified	
			,T1.Attributes	
			,T1.Size
	FROM		dbaadmin.dbo.dbaudf_DirectoryList2(@FilePath,@DBName+'*',@IncludeSubDir) T1
	JOIN		(
			SELECT	@DBName+'_DB_%' [Name],'DB' [BackupType]
			UNION ALL
			SELECT	@DBName+'_FG$%','FG'
			UNION ALL
			SELECT	@DBName+'_DFNTL_%','DF'
			UNION ALL
			SELECT	@DBName+'_TLOG_%','TL'
			UNION ALL
			SELECT	@DBName+'%.trn','TL'
			UNION ALL
			SELECT	@DBName+'_BASE_%','DB'
			UNION ALL
			SELECT	@ForceFileName +'%','??'
			) T2
		ON	REPLACE(T1.[Name],'_DB_FG_','_FG$') LIKE T2.Name
)
