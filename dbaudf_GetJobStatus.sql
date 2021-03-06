USE [DBAadmin]
GO
/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetJobStatus]    Script Date: 9/18/2014 12:56:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[dbaudf_GetJobStatus] ( 
    @pJobName varchar(100) 
) 
RETURNS int
AS
-- ============================================= 
-- Author:      Steve Ledridge 
-- Create date: 10/29/2012
-- Description: Gets state of particular Job 
-- 
-- NULL = Job was not Found 
-- NEGATIVE VALUE = Job is Disabled 
--  1 = Failed 
--  2 = Succeeded 
--  3 = Retry 
--  4 = Canceled 
--  5 = In progress 
--  6 = Idle
-- ============================================= 

BEGIN
    DECLARE @status int 
    DECLARE @Factor INT   
 
    SELECT
	@Factor = CASE WHEN O.enabled = 0 THEN -1 ELSE 1 END
        ,@status = CASE
			WHEN OA.run_requested_date IS NULL THEN 6
			ELSE ISNULL(JH.RUN_STATUS, 4)+1
			END       
    FROM MSDB.DBO.SYSJOBS O 
    INNER JOIN MSDB.DBO.SYSJOBACTIVITY OA ON (O.job_id = OA.job_id) 
    INNER JOIN (SELECT MAX(SESSION_ID) AS SESSION_ID FROM MSDB.DBO.SYSSESSIONS ) AS S ON (OA.session_ID = S.SESSION_ID) 
    LEFT JOIN MSDB.DBO.SYSJOBHISTORY JH ON (OA.job_history_id = JH.instance_id) 
    WHERE O.name = @pJobName 
 
    RETURN @status * @Factor
END
