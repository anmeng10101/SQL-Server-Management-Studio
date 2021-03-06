USE [DEPLcontrol]
GO
/****** Object:  StoredProcedure [dbo].[dpsp_ahp_Script_PreRelease]    Script Date: 10/4/2013 11:02:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[dpsp_ahp_Script_PreRelease] (@request_id int = null)

/*********************************************************
 **  Stored Procedure dpsp_ahp_Script_PreRelease                  
 **  Written by Steve Ledridge, Getty Images                
 **  December 14, 2009                                      
 **  
 **  This sproc will assist in manually scripting the start of
 **  the pre-release Backup Jobs in stage and production.  
 **
 **  Input Parm(s);
 **  @request_id - is the Gears ID for a specific request
 **
 ***************************************************************/
as
set nocount on

--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	12/14/2009	Steve Ledridge		New process.
--	03/02/2011	Steve Ledridge		New version created for ahp.
--	======================================================================================

/***
Declare @request_id int
Select @request_id = 41496
--***/

-----------------  declares  ------------------

DECLARE
	 @miscprint		nvarchar(2000)
	,@cmd			nvarChar(4000)
	,@update_flag		char(1)
	,@error_count		int
	,@JobName		nVarChar(4000)
	,@query			nVarChar(4000)

/*********************************************************************
 *                Initialization
 ********************************************************************/
SET		@error_count	= 0
SET		@update_flag	= 'n'
SET		@JobName	= 'SPCL - PreRelease Backups'
SET		@query		= 'exec msdb.dbo.sp_Start_Job @job_name=''''' 
					+ @JobName 
					+ ''''';'

----------------------  Print the headers  ----------------------

Print  '/*******************************************************************'
Select @miscprint = '   SQL Automated Deployment Requests - Server: ' + @@servername
Print  @miscprint
Print  ' '
Select @miscprint = '-- Script Starting of PreRelease Backup Jobs '
Print  @miscprint
Print  '*******************************************************************/'
Print  ' '


--  Verify input parms

If @request_id is null
   begin
	Select @miscprint = 'Error: No Gears ID specified.' 
	Print  @miscprint
	Print ''

	exec dbo.dpsp_ahp_Status @report_only = 'y'

	goto label99
   end


/****************************************************************
 *                MainLine
 ***************************************************************/

	SET    @cmd		= ''
	select @cmd		= @cmd	+ '/***'
							+ CHAR(13) + CHAR(10)
							+ 'DECLARE @CMD nVarChar(4000)'
							+ CHAR(13) + CHAR(10)
							+ 'SET @CMD = ''sqlcmd -S' 
							+ d.TargetSQLname 
							+ ' -dmsdb -E -Q"' 
							+ @query + '"'''
							+ CHAR(13) + CHAR(10)
							+ 'exec master.sys.xp_cmdshell @cmd , no_output'
							+ CHAR(13) + CHAR(10)
							+ '--***/'
							+ CHAR(13) + CHAR(10)
							+ 'GO'
							+ CHAR(13) + CHAR(10)
							+ CHAR(13) + CHAR(10)
	FROM		(
				SELECT DISTINCT
				d.TargetSQLname                         
				From   dbo.AHP_Import_Requests d
				WHERE  d.request_id = @request_id
				) d

	PRINT (@CMD)               

	Set @update_flag = 'y'	

	goto label99

-----------------  Finalizations  ------------------

label99:

If @update_flag = 'n'
   begin
	Print  ' '
	Print  ' '
	Select @miscprint = '--Here is a sample execute command for this sproc:'
	Print  @miscprint
	Print  ' '
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_ahp_Script_PreRelease @request_id = 12345'
	Print  @miscprint
	Print  'go'
	Print  ' '
   end



GO
