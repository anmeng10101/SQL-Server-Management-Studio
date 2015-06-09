
SELECT		[Site]
		,VMI.ClusterName
		,VMI.ESXIHostName
		,COUNT(DISTINCT SI.ServerName)
		,dbaadmin.dbo.dbaudf_ConcatenateUnique(SI.ServerName) AS [Servers]


FROM		dbacentral.dbo.DBA_ServerInfo SI
LEFT JOIN	(
		SELECT		'Seattle' collate SQL_Latin1_General_CP1_CI_AS AS [Site]
				,VPG.[NAME] collate SQL_Latin1_General_CP1_CI_AS AS VMGuestLogicalName
				, VPH.[NAME] collate SQL_Latin1_General_CP1_CI_AS AS ESXIHostName
				, ISNULL(VPG.[DNS_NAME],'') collate SQL_Latin1_General_CP1_CI_AS AS DNS_NAME
				, ISNULL(VPG.[IP_ADDRESS],'') collate SQL_Latin1_General_CP1_CI_AS AS IP_ADDRESS
				, VCR.NAME collate SQL_Latin1_General_CP1_CI_AS AS ClusterName
		FROM		[SEAPVCENTSQL].[VCDB].[dbo].[VPXV_VMS] AS VPG WITH (NOLOCK,NOWAIT)
		JOIN		[SEAPVCENTSQL].[VCDB].[dbo].[VPXV_HOSTS] AS VPH WITH (NOLOCK,NOWAIT)
			ON	VPH.HOSTID = VPG.HOSTID
		LEFT JOIN	[SEAPVCENTSQL].[VCDB].[dbo].[VPXV_RESOURCE_POOL] AS VRP WITH (NOLOCK,NOWAIT)
			ON	VRP.RESOURCEPOOLID = VPG.RESOURCE_GROUP_ID
		LEFT JOIN	[SEAPVCENTSQL].[VCDB].[dbo].[VPXV_COMPUTE_RESOURCE] AS VCR  WITH (NOLOCK,NOWAIT)
			ON	VCR.RESOURCEPOOLID = VRP.PARENT_ID

		UNION

		SELECT		'Ashburn' collate SQL_Latin1_General_CP1_CI_AS AS [Site]
				,VPG.[NAME] collate SQL_Latin1_General_CP1_CI_AS AS VMGuestLogicalName
				, VPH.[NAME] collate SQL_Latin1_General_CP1_CI_AS AS ESXIHostName
				, ISNULL(VPG.[DNS_NAME],'') collate SQL_Latin1_General_CP1_CI_AS AS DNS_NAME
				, ISNULL(VPG.[IP_ADDRESS],'') collate SQL_Latin1_General_CP1_CI_AS AS IP_ADDRESS
				, VCR.NAME collate SQL_Latin1_General_CP1_CI_AS AS ClusterName
		FROM		[ASHPSQLVCTRA].[VCDB].[dbo].[VPXV_VMS] AS VPG WITH (NOLOCK,NOWAIT)
		JOIN		[ASHPSQLVCTRA].[VCDB].[dbo].[VPXV_HOSTS] AS VPH WITH (NOLOCK,NOWAIT)
			ON	VPH.HOSTID = VPG.HOSTID
		LEFT JOIN	[ASHPSQLVCTRA].[VCDB].[dbo].[VPXV_RESOURCE_POOL] AS VRP WITH (NOLOCK,NOWAIT)
			ON	VRP.RESOURCEPOOLID = VPG.RESOURCE_GROUP_ID
		LEFT JOIN	[ASHPSQLVCTRA].[VCDB].[dbo].[VPXV_COMPUTE_RESOURCE] AS VCR  WITH (NOLOCK,NOWAIT)
			ON	VCR.RESOURCEPOOLID = VRP.PARENT_ID

		) VMI
ON		SI.ServerName collate SQL_Latin1_General_CP1_CI_AS  = VMI.VMGuestLogicalName
	OR	VMI.DNS_NAME LIKE '%'+ SI.ServerName collate SQL_Latin1_General_CP1_CI_AS + '%'




WHERE		SI.SQLEnv = 'production'
	AND	SI.Active != 'N'
	AND	SI.SystemModel Like '%VMware%'

GROUP BY	[Site]
		,VMI.ClusterName  
		,VMI.ESXIHostName

ORDER BY	1,2,3


