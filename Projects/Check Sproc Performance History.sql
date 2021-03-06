SELECT		Daily.*
			-- Negative is better than weekly avg
			,Daily.[AVG_Duration]-LastWeek.[AVG_Duration] [DEV_Duration]
			,Daily.[AVG_Reads]-LastWeek.[AVG_Reads] [DEV_Reads]

			,LastWeek.[AVG_Duration] [LW_AVG_Duration]
			,LastWeek.[AVG_Reads] [LW_AVG_Reads]			
FROM		(
			SELECT		DB_NAME([dbid]) [DBName]
						,[dbid]
						,[ObjectName]
						,YEAR([rundate]) [year]
						,MONTH([rundate]) [month]
						,DAY([rundate]) [day]
						,AVG([AVG_Duration]) [AVG_Duration]
						,AVG([AVG_Reads]) [AVG_Reads]
			FROM		(			
						SELECT		[dbid]
									,OBJECT_NAME([objectid],[dbid]) [ObjectName]
									,[rundate]
									,SUM([delta_elapsed_time]/[execution_count])	[AVG_Duration]
									,SUM([delta_logical_reads]/[execution_count])	[AVG_Reads]
									,MAX([execution_count])							[execution_count]
						FROM		[DBAperf].[dbo].[DMV_QueryDaily_log]
						WHERE		OBJECT_NAME([objectid],[dbid]) IS NOT NULL
						GROUP BY	[dbid]
									,OBJECT_NAME([objectid],[dbid])
									,[rundate]
						) DATA
			GROUP BY	[dbid]
						,[ObjectName]
						,YEAR([rundate])
						,MONTH([rundate])
						,DAY([rundate])
			) Daily
JOIN		(
			SELECT		[dbid]
						,[ObjectName]
						,AVG([AVG_Duration]) [AVG_Duration]
						,AVG([AVG_Reads]) [AVG_Reads]
			FROM		(			
						SELECT		[dbid]
									,OBJECT_NAME([objectid],[dbid]) [ObjectName]
									,[rundate]
									,SUM([delta_elapsed_time]/[execution_count])	[AVG_Duration]
									,SUM([delta_logical_reads]/[execution_count])	[AVG_Reads]
									,MAX([execution_count])							[execution_count]
						FROM		[DBAperf].[dbo].[DMV_QueryDaily_log]
						WHERE		OBJECT_NAME([objectid],[dbid]) IS NOT NULL
							AND		[rundate] > GetDate() -7
						GROUP BY	[dbid]
									,OBJECT_NAME([objectid],[dbid])
									,[rundate]
						) DATA
			GROUP BY	[dbid]
						,[ObjectName]
			) LastWeek
	ON		Daily.[dbid] = LastWeek.[dbid]
	AND		Daily.[ObjectName] = LastWeek.[ObjectName]


ORDER BY	1,2,3,4		
		