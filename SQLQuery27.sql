--select 
--  (select 'ServerName' as th for xml path(''), type),
--  (select 'SQLNAME' as th for xml path(''), type),
--  (select 'Port' as th for xml path(''), type),
--  (select 'DomainName' as th for xml path(''), type),
--  (select 'SQLEnv' as th for xml path(''), type),
--  (select 'SQLver' as th for xml path(''), type),
--  (select 'SQL_Version' as th for xml path(''), type),
--  (select 'SQL_Build' as th for xml path(''), type),
--  (select 'SQL_Edition' as th for xml path(''), type),
--  (select 'SQL_BitLevel' as th for xml path(''), type),
--  (select 'CPU_Physical' as th for xml path(''), type),
--  (select 'CPU_Cores' as th for xml path(''), type),
--  (select 'CPU_Logical' as th for xml path(''), type),
--  (select 'CPU_BitLevel' as th for xml path(''), type),
--  (select 'CPU_Speed' as th for xml path(''), type),
--  (select 'OS_Version' as th for xml path(''), type),
--  (select 'OS_Build' as th for xml path(''), type),
--  (select 'OS_Edition' as th for xml path(''), type),
--  (select 'OS_BitLevel' as th for xml path(''), type),
--  (select 'OPSDBVersion_DBAADMIN' as th for xml path(''), type),
--  (select 'OPSDBVersion_DBAPERF' as th for xml path(''), type),
--  (select 'OPSDBVersion_SQLdeploy' as th for xml path(''), type),
--  (select 'MEM_MB_Total' as th for xml path(''), type),
--  (select 'MEM_MB_SQLMax' as th for xml path(''), type),
--  (select 'MEM_MB_PageFileMax' as th for xml path(''), type),
--  (select 'MEM_MB_PageFileAvailable' as th for xml path(''), type),
--  (select 'MEM_MB_PageFileInUse' as th for xml path(''), type),
--  (select 'MDACver' as th for xml path(''), type),
--  (select 'IEver' as th for xml path(''), type),
--  (select 'AntiVirus_type' as th for xml path(''), type),
--  (select 'AntiVirus_Excludes' as th for xml path(''), type),
--  (select 'awe_enabled' as th for xml path(''), type),
--  (select 'boot_3gb' as th for xml path(''), type),
--  (select 'boot_pae' as th for xml path(''), type),
--  (select 'boot_userva' as th for xml path(''), type),
--  (select 'iscluster' as th for xml path(''), type),
--  (select 'Active' as th for xml path(''), type),
--  (select 'Filescan' as th for xml path(''), type),
--  (select 'SQLMail' as th for xml path(''), type),
--  (select 'SQLScanforStartupSprocs' as th for xml path(''), type),
--  (select 'LiteSpeed' as th for xml path(''), type),
--  (select 'RedGate' as th for xml path(''), type),
--  (select 'IndxSnapshot_process' as th for xml path(''), type),
--  (select 'SAN' as th for xml path(''), type),
--  (select 'FullTextCat' as th for xml path(''), type),
--  (select 'Mirroring' as th for xml path(''), type),
--  (select 'Repl_Flag' as th for xml path(''), type),
--  (select 'LogShipping' as th for xml path(''), type),
--  (select 'LinkedServers' as th for xml path(''), type),
--  (select 'ReportingSvcs' as th for xml path(''), type),
--  (select 'LocalPasswords' as th for xml path(''), type),
--  (select 'DEPLstatus' as th for xml path(''), type),
--  (select 'IndxSnapshot_inverval' as th for xml path(''), type),
--  (select 'backup_type' as th for xml path(''), type),
--  (select 'MAXdop_value' as th for xml path(''), type),
--  (select 'tempdb_filecount' as th for xml path(''), type),
--  (select 'DateTime_Offset' as th for xml path(''), type),
--  (select 'modDate' as th for xml path(''), type),
--  (select 'SQLinstallDate' as th for xml path(''), type),
--  (select 'SQLinstallBy' as th for xml path(''), type),
--  (select 'SQLrecycleDate' as th for xml path(''), type),
--  (select 'OSinstallDate' as th for xml path(''), type),
--  (select 'OSuptime' as th for xml path(''), type),
--  (select 'MOMverifyDate' as th for xml path(''), type),
--  (select 'SQLSvcAcct' as th for xml path(''), type),
--  (select 'SQLAgentAcct' as th for xml path(''), type),
--  (select 'Assemblies' as th for xml path(''), type),
--  (select 'CLR_state' as th for xml path(''), type),
--  (select 'FrameWork_ver' as th for xml path(''), type),
--  (select 'FrameWork_dir' as th for xml path(''), type),
--  (select 'OracleClient' as th for xml path(''), type),
--  (select 'TNSnamesPath' as th for xml path(''), type),
--  (select 'Location' as th for xml path(''), type),
--  (select 'IPnum' as th for xml path(''), type)
--union all 
--SELECT (select [ServerName]  as 'td' for xml path(''), type)
--      ,(select [SQLNAME]  as 'td' for xml path(''), type)
--      ,(select [Port]  as 'td' for xml path(''), type)
--      ,(select [DomainName]  as 'td' for xml path(''), type)
--      ,(select [SQLEnv]  as 'td' for xml path(''), type)
--      ,(select [SQLver]  as 'td' for xml path(''), type)
--      ,(select [SQL_Version]  as 'td' for xml path(''), type)
--      ,(select [SQL_Build]  as 'td' for xml path(''), type)
--      ,(select [SQL_Edition]  as 'td' for xml path(''), type)
--      ,(select [SQL_BitLevel]  as 'td' for xml path(''), type)
--      ,(select [CPU_Physical]  as 'td' for xml path(''), type)
--      ,(select [CPU_Cores]  as 'td' for xml path(''), type)
--      ,(select [CPU_Logical]  as 'td' for xml path(''), type)
--      ,(select [CPU_BitLevel]  as 'td' for xml path(''), type)
--      ,(select [CPU_Speed]  as 'td' for xml path(''), type)
--      ,(select [OS_Version]  as 'td' for xml path(''), type)
--      ,(select [OS_Build]  as 'td' for xml path(''), type)
--      ,(select [OS_Edition]  as 'td' for xml path(''), type)
--      ,(select [OS_BitLevel]  as 'td' for xml path(''), type)
--      ,(select [OPSDBVersion_DBAADMIN]  as 'td' for xml path(''), type)
--      ,(select [OPSDBVersion_DBAPERF]  as 'td' for xml path(''), type)
--      ,(select [OPSDBVersion_SQLdeploy]  as 'td' for xml path(''), type)
--      ,(select [MEM_MB_Total]  as 'td' for xml path(''), type)
--      ,(select [MEM_MB_SQLMax]  as 'td' for xml path(''), type)
--      ,(select [MEM_MB_PageFileMax]  as 'td' for xml path(''), type)
--      ,(select [MEM_MB_PageFileAvailable]  as 'td' for xml path(''), type)
--      ,(select [MEM_MB_PageFileInUse]  as 'td' for xml path(''), type)
--      ,(select [MDACver]  as 'td' for xml path(''), type)
--      ,(select [IEver]  as 'td' for xml path(''), type)
--      ,(select [AntiVirus_type]  as 'td' for xml path(''), type)
--      ,(select [AntiVirus_Excludes]  as 'td' for xml path(''), type)
--      ,(select [awe_enabled]  as 'td' for xml path(''), type)
--      ,(select [boot_3gb]  as 'td' for xml path(''), type)
--      ,(select [boot_pae]  as 'td' for xml path(''), type)
--      ,(select [boot_userva]  as 'td' for xml path(''), type)
--      ,(select [iscluster]  as 'td' for xml path(''), type)
--      ,(select [Active]  as 'td' for xml path(''), type)
--      ,(select [Filescan]  as 'td' for xml path(''), type)
--      ,(select [SQLMail]  as 'td' for xml path(''), type)
--      ,(select [SQLScanforStartupSprocs]  as 'td' for xml path(''), type)
--      ,(select [LiteSpeed]  as 'td' for xml path(''), type)
--      ,(select [RedGate]  as 'td' for xml path(''), type)
--      ,(select [IndxSnapshot_process]  as 'td' for xml path(''), type)
--      ,(select [SAN]  as 'td' for xml path(''), type)
--      ,(select [FullTextCat]  as 'td' for xml path(''), type)
--      ,(select [Mirroring]  as 'td' for xml path(''), type)
--      ,(select [Repl_Flag]  as 'td' for xml path(''), type)
--      ,(select [LogShipping]  as 'td' for xml path(''), type)
--      ,(select [LinkedServers]  as 'td' for xml path(''), type)
--      ,(select [ReportingSvcs]  as 'td' for xml path(''), type)
--      ,(select [LocalPasswords]  as 'td' for xml path(''), type)
--      ,(select [DEPLstatus]  as 'td' for xml path(''), type)
--      ,(select [IndxSnapshot_inverval]  as 'td' for xml path(''), type)
--      ,(select [backup_type]  as 'td' for xml path(''), type)
--      ,(select [MAXdop_value]  as 'td' for xml path(''), type)
--      ,(select [tempdb_filecount]  as 'td' for xml path(''), type)
--      ,(select [DateTime_Offset]  as 'td' for xml path(''), type)
--      ,(select [modDate]  as 'td' for xml path(''), type)
--      ,(select [SQLinstallDate]  as 'td' for xml path(''), type)
--      ,(select [SQLinstallBy]  as 'td' for xml path(''), type)
--      ,(select [SQLrecycleDate]  as 'td' for xml path(''), type)
--      ,(select [OSinstallDate]  as 'td' for xml path(''), type)
--      ,(select [OSuptime]  as 'td' for xml path(''), type)
--      ,(select [MOMverifyDate]  as 'td' for xml path(''), type)
--      ,(select [SQLSvcAcct]  as 'td' for xml path(''), type)
--      ,(select [SQLAgentAcct]  as 'td' for xml path(''), type)
--      ,(select [Assemblies]  as 'td' for xml path(''), type)
--      ,(select [CLR_state]  as 'td' for xml path(''), type)
--      ,(select [FrameWork_ver]  as 'td' for xml path(''), type)
--      ,(select [FrameWork_dir]  as 'td' for xml path(''), type)
--      ,(select [OracleClient]  as 'td' for xml path(''), type)
--      ,(select [TNSnamesPath]  as 'td' for xml path(''), type)
--      ,(select [Location]  as 'td' for xml path(''), type)
--      ,(select [IPnum]  as 'td' for xml path(''), type)
--  FROM [dbacentral].[dbo].[ServerInfo]
--  for xml path('tr')
  



--SELECT		row
--		,(rn-((row-1)*5)) col
--		,SQLName
--FROM		(
--		SELECT		TOP 100 PERCENT
--				((rn-1)/5+1) row
--				,rn
--				,SqlName
--		FROM		(
--				SELECT		row_number()over(order by SQLName) rn
--						,SQLNAME
--				FROM		[dbacentral].[dbo].[ServerInfo]
		
--				) Data
--		order by	SQLName
--		) Data



--SELECT	'<table class="ms-rteTable-default ">'
--UNION ALL
--SELECT	'     <tbody>'
--UNION ALL
--SELECT		'          <tr><td>'+REPLACE(dbaadmin.dbo.dbaudf_ConcatenateUnique('[['+LinkName+']]'),',','</td><td>')+'</td></tr>'
--FROM		(
--		SELECT		TOP 100 PERCENT
--				((rn-1)/5+1) row
--				,rn
--				,LinkName
--		FROM		(
--				SELECT		DISTINCT
--						row_number()over(order by SQLName) rn
--						,SQLNAME LinkName
--				FROM		[dbacentral].[dbo].[ServerInfo]
		
--				) Data
--		order by	LinkName
--		) Data
--GROUP BY	row
--UNION ALL
--SELECT	'     </tbody>'
--UNION ALL
--SELECT	'</table>'




--SELECT top 10 * FROM [dbacentral].[dbo].[ServerInfo]
--GO
--SELECT top 10 * FROM [dbacentral].[dbo].DBA_DBInfo
--GO

DECLARE		@TableWidth	INT
SET		@TableWidth	= 3

;WITH		[Set_All]
		AS
		(
		SELECT		1					[row]
				,'[[ALL]],[[ACTIVE]],[[NOT ACTIVE]]'	[LinkSet]
				,3					[SetSize]
		)
		,[Set_Domain]
		AS
		(
		SELECT		row
				,dbaadmin.dbo.dbaudf_ConcatenateUnique('[['+LinkName+']]') [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		row_number()over(order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									UPPER(DomainName) LinkName
								FROM	[dbacentral].[dbo].[ServerInfo]
								WHERE	Active = 'y'
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	LinkName
				)Data
		GROUP BY	row
		)
		,[Set_SQLVersion]
		AS
		(
		SELECT		row
				,dbaadmin.dbo.dbaudf_ConcatenateUnique('[['+LinkName+']]') [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		row_number()over(order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									UPPER(SQL_Version) LinkName
								FROM	[dbacentral].[dbo].[ServerInfo]
								WHERE	Active = 'y'
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	LinkName
				)Data
		GROUP BY	row
		)
		,[Set_Environment]
		AS
		(
		SELECT		row
				,dbaadmin.dbo.dbaudf_ConcatenateUnique('[['+LinkName+']]') [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		row_number()over(order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									UPPER(SQLEnv) LinkName
								FROM	[dbacentral].[dbo].[ServerInfo]
								WHERE	Active = 'y'
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	LinkName
				)Data
		GROUP BY	row
		)
		,[Set_App]
		AS
		(
		SELECT		row
				,dbaadmin.dbo.dbaudf_ConcatenateUnique('[['+LinkName+']]') [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		row_number()over(order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									UPPER(REPLACE(Appl_desc,',','&#44;')) LinkName
								FROM	[dbacentral].[dbo].[DBA_DBInfo]
								WHERE	SQLName IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE	Active = 'y')
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	LinkName
				)Data
		GROUP BY	row
		)
		,[Set_DB]
		AS
		(
		SELECT		row
				,dbaadmin.dbo.dbaudf_ConcatenateUnique('[['+LinkName+']]') [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		row_number()over(order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									UPPER(COALESCE(T2.DBName_Cleaned,T3.DBName_Cleaned,T1.DBName)) LinkName
								FROM	[dbacentral].[dbo].[DBA_DBInfo] T1
								LEFT 
								JOIN	[dbacentral].[dbo].[DBA_DBNameCleaner] T2
								  ON	T1.DBName Like T2.DBName
								LEFT
								JOIN	(
									SELECT	DISTINCT
										[DBName_Cleaned]+'%' [DBName]
										,[DBName_Cleaned]
									FROM	[dbacentral].[dbo].[DBA_DBNameCleaner]
									) T3
								  ON	T1.DBName Like T3.DBName
								WHERE	SQLName IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE	Active = 'y')
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	LinkName
				)Data
		GROUP BY	row
		)




SELECT	'<table class="ms-rteTable-default ">'
UNION ALL
SELECT	'     <tbody>'
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'"></div></td></tr>'
---------------------------------------------------------------------------------------
UNION ALL
SELECT		'          <tr><td>'+REPLACE([LinkSet],',','</td><td>')+'</td>'
		+ ISNULL(REPLICATE('<td></td>',@TableWidth-[SetSize]),'')
		+'</tr>'
FROM		[Set_All]
---------------------------------------------------------------------------------------
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'"></td></tr>'
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'"><h2>DOMAIN</h2></td></tr>'
UNION ALL
SELECT	'          <tr><td>'+REPLACE([LinkSet],',','</td><td>')+'</td>'
		+ ISNULL(REPLICATE('<td></td>',@TableWidth-[SetSize]),'')
		+'</tr>'
FROM		[Set_Domain]
---------------------------------------------------------------------------------------
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'"></td></tr>'
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'"><h2>SQL VERSION</h2></td></tr>'
UNION ALL
SELECT	'          <tr><td>'+REPLACE([LinkSet],',','</td><td>')+'</td>'
		+ ISNULL(REPLICATE('<td></td>',@TableWidth-[SetSize]),'')
		+'</tr>'
FROM		[Set_SQLVersion]
---------------------------------------------------------------------------------------
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'"></td></tr>'
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'"><h2>ENVIRONMENT</h2></td></tr>'
UNION ALL
SELECT	'          <tr><td>'+REPLACE([LinkSet],',','</td><td>')+'</td>'
		+ ISNULL(REPLICATE('<td></td>',@TableWidth-[SetSize]),'')
		+'</tr>'
FROM		[Set_Environment]
---------------------------------------------------------------------------------------
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'"></td></tr>'
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'"><h2>APPLICATIONS</h2></td></tr>'
UNION ALL
SELECT	'          <tr><td>'+REPLACE([LinkSet],',','</td><td>')+'</td>'
		+ ISNULL(REPLICATE('<td></td>',@TableWidth-[SetSize]),'')
		+'</tr>'
FROM		[Set_App]
---------------------------------------------------------------------------------------
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'"></td></tr>'
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'"><h2>DATABASES</h2></td></tr>'
UNION ALL
SELECT	'          <tr><td>'+REPLACE([LinkSet],',','</td><td>')+'</td>'
		+ ISNULL(REPLICATE('<td></td>',@TableWidth-[SetSize]),'')
		+'</tr>'
FROM		[Set_DB]






UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'"></td></tr>'
UNION ALL
SELECT	'     </tbody>'
UNION ALL
SELECT	'</table>'























--SELECT	Number row
--	,'' LinkName 
--From	dbaadmin.dbo.dbaudf_NumberTable(1,5,1)

