USE [DEPLcontrol]
GO
/****** Object:  StoredProcedure [dbo].[dpsp_Approve]    Script Date: 10/4/2013 11:02:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[dpsp_Approve] (@gears_id int = null
				,@auto char(1) = 'n'
				,@runtype nvarchar(10) = null
				,@DBA_override char(1) = 'n')

/*********************************************************
 **  Stored Procedure dpsp_Approve                  
 **  Written by Jim Wilson, Getty Images                
 **  January 26, 2009                                      
 **  
 **  This sproc will mark specific Gears requests as approved
 **  prior to SQL deployment processing.
 **
 **  Input Par(s);
 **  @gears_id - is the Gears ID for a specific request
 **
 **  @auto - suppresses the examples at the end.
 **
 **  @runtype - Mostly for stage and production, this sets the request
 **            to be run manually by SQLname using the sproc
 **            dpsp_ManualStart.
 **
 **  @DBA_override - Set override needed to dba_ok (y or n).
 **
 ***************************************************************/
  as
set nocount on

--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	01/26/2009	Jim Wilson		New process.
--	02/25/2009	Jim Wilson		Added reference to requestdate column in dbo.request table.
--	03/03/2009	Jim Wilson		Added @auto input parm.
--	04/09/2009	Jim Wilson		Added @manual input parm and related functions.
--	04/28/2009	Jim Wilson		Changed @manual input parm to @runtype.
--	04/29/2009	Jim Wilson		New cleanup code for @save_notes.
--	06/08/2009	Jim Wilson		Converted all echo commands to sqlcmd.
--	07/13/2009	Jim Wilson		Added @DBA_override input parm.
--	07/14/2009	Jim Wilson		Fix status for stage requests.  Was hard coded to pending. Oops.
--	06/02/2010	Jim Wilson		Changed seafrestgsql to fresdbasql01. 
--	======================================================================================


/***
Declare @gears_id int
Declare @auto char(1)
Declare @runtype nvarchar(10)
Declare @DBA_override char(1)

Select @gears_id = 36930
Select @auto = 'n'
Select @runtype = 'manual'
Select @DBA_override = 'n'
--***/

-----------------  declares  ------------------

DECLARE
	 @miscprint			nvarchar(2000)
	,@cmd				nvarchar(4000)
	,@charpos			int
	,@update_flag			char(1)
	,@save_servername		sysname
	,@save_servername2		sysname
	,@save_start_d			nvarchar(50)
	,@save_start_t			nvarchar(50)
	,@save_RequestDate		datetime
	,@save_start_date		datetime
	,@save_detail_id		int
	,@save_DBname			sysname
	,@save_Start			sysname
	,@error_count			int
	,@DateStmp 			char(14)
	,@Hold_hhmmss			varchar(8)
	,@outfile_name			sysname
	,@outfile_path			nvarchar(2000)
	,@hold_source_path		nvarchar(2000)
	,@prodstage_flag		char(1)

DECLARE
	 @save_ProjectName		sysname
	,@save_ProjectNum		sysname
	,@save_StartDate		datetime
	,@save_StartTime		nvarchar(50)
	,@save_Environment		sysname
	,@save_Notes			nvarchar(4000)
	,@save_DBAapproved		char(01)
	,@save_DBAapprover		sysname
	,@save_Status			sysname
	,@save_ModDate			datetime
	,@save_reqdet_id		int
	,@save_APPLname			sysname
	,@save_SQLname			sysname
	,@save_BASEfolder		sysname
	,@save_Process			sysname
	,@save_ProcessType		sysname
	,@save_ProcessDetail		sysname 


/*********************************************************************
 *                Initialization
 ********************************************************************/
Select @error_count = 0
Select @update_flag = 'n'
Select @prodstage_flag = 'n'

Select @save_servername = @@servername
Select @save_servername2 = @@servername

Select @charpos = charindex('\', @save_servername)
IF @charpos <> 0
   begin
	Select @save_servername = substring(@@servername, 1, (CHARINDEX('\', @@servername)-1))

	Select @save_servername2 = stuff(@save_servername2, @charpos, 1, '$')
   end


--  Create temp table
CREATE TABLE #temp_reqdet (reqdet_id int)





----------------------  Print the headers  ----------------------

Print  '/*******************************************************************'
Select @miscprint = '   SQL Automated Deployment Requests - Server: ' + @@servername
Print  @miscprint
Print  ' '
Select @miscprint = '-- Gears Request Approval Process '
Print  @miscprint
Print  '*******************************************************************/'
Print  ' '


--  Verify input parms
If @gears_id is null
   begin
	Select @miscprint = 'DBA WARNING: Invalid input for parm @gears_id (' + convert(nvarchar(20), @gears_id) + ').  A vaild gears_id must be input.' 
	Print  @miscprint
	Print ''
	Select @error_count = @error_count + 1
	Select @gears_id = null
	goto label99
   end


If not exists (select 1 from dbo.request where gears_id = @gears_id)
   begin
	Select @miscprint = 'DBA WARNING: Invalid input for parm @gears_id (' + convert(nvarchar(20), @gears_id) + ').  No rows for this gears_id in the Request table.' 
	Print  @miscprint
	Print ''
	Select @error_count = @error_count + 1
	Select @gears_id = null
	goto label99
   end

--  check stage and production related requests
If exists (select 1 from dbo.Request where gears_id = @gears_id and Environment like '%stag%')
   begin
	Select @prodstage_flag = 'y'

	If @runtype is null or @runtype not in ('auto', 'manual')
	   begin
		Select @miscprint = 'DBA WARNING: @runtype input parm (''auto'' or ''manual'') must be specified for @gears_id (' + convert(nvarchar(20), @gears_id) + ').  This input parm is required for all stage requests.' 
		Print  @miscprint
		Print ''
		Select @error_count = @error_count + 1
		Select @gears_id = null
		goto label99
	   end
   end

If exists (select 1 from dbo.Request where gears_id = @gears_id and Environment like '%prod%')
   begin
	Select @prodstage_flag = 'y'

	If @runtype is null or @runtype <> 'manual'
	   begin
		Select @miscprint = 'DBA WARNING: @runtype input parm must be specified for @gears_id (' + convert(nvarchar(20), @gears_id) + ').  @runtype = ''manual'' is required for all production requests.' 
		Print  @miscprint
		Print ''
		Select @error_count = @error_count + 1
		Select @gears_id = null
		goto label99
	   end
   end


--  Set override if requested
If @DBA_override = 'y'
   begin
	update dbo.Request_detail set ProcessType = 'DBA-ok' where gears_id = @gears_id and ProcessType like '%Override_Needed%'
   end




/****************************************************************
 *                MainLine
 ***************************************************************/



--  Check to see if the request still needs overrides
If exists (select 1 from dbo.Request_detail where gears_id = @gears_id and ProcessType like '%Override_Needed%')
   begin
	Select @miscprint = '--*****************************************************************************************************************************************************'
	Print  @miscprint
	Select @miscprint = '--DBA WARNING: This Gears Request needs an OVERRIDE before it can be approved.' 
	Print  @miscprint
	Select @miscprint = '--             Please use the @DBA_override input parm, or cancel the detail item(s) in question.' 
	Print  @miscprint
	Select @miscprint = '--             You can use "dbo.dpsp_Update @gears_id = ' + convert(nvarchar(20), @gears_id) + '" to cancel the detail item.' 
	Print  @miscprint
	Select @miscprint = '--*****************************************************************************************************************************************************'
	Print  @miscprint
	Print ''
	goto label99
   end


--  Check to make sure the start time is set correctly
If exists (select 1 from dbo.Request where gears_id = @gears_id and StartTime like 'z%')
   begin
	Select @miscprint = '--*****************************************************************************************************************************************************'
	Print  @miscprint
	Select @miscprint = '--DBA WARNING: This Gears Request needs its StartTime adjusted before it can be approved.' 
	Print  @miscprint
	Select @miscprint = '--             Please change the StartTime to a valid start time (e.g. 14:30).' 
	Print  @miscprint
	Select @miscprint = '--             Use "dbo.dpsp_Update @gears_id = ' + convert(nvarchar(20), @gears_id) + '" to make that change.' 
	Print  @miscprint
	Select @miscprint = '--*****************************************************************************************************************************************************'
	Print  @miscprint
	Print ''
	goto label99
   end


--  Approve the request

--  For manual approvals, set the request_detail status for this gears_id
If @runtype = 'manual'
   begin
	update dbo.Request_detail set status = 'manual' where gears_id = @gears_id
   end

update dbo.Request set DBAapproved = 'y', DBAapprover = suser_name() where gears_id = @gears_id
Select @update_flag = 'y'

Select @miscprint = '--***************************************************************************'
Print  @miscprint
Select @miscprint = '--Gears Request ' + convert(nvarchar(20), @gears_id) + ' Approved.' 
Print  @miscprint
Select @miscprint = '--***************************************************************************'
Print  @miscprint
Print ''


--  If there are detail records for stage, send that data to the central servers in the stage domain
If exists (select 1 from dbo.request_detail where gears_id = @gears_id and domain = 'stage')
   begin
	--  Create output file for stage
	Set @Hold_hhmmss = convert(varchar(8), getdate(), 8)
	Set @DateStmp = convert(char(8), getdate(), 112) + substring(@Hold_hhmmss, 1, 2) + substring(@Hold_hhmmss, 4, 2) + substring(@Hold_hhmmss, 7, 2) 

	Select @outfile_name = 'DEPLcontrolUpdate_STAGE_' + @DateStmp + '.gsql'
	Select @outfile_path = '\\' + @save_servername + '\' + @save_servername2 + '_dbasql\dba_reports\' + @outfile_name
	Select @cmd = 'copy nul ' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd, no_output

	Select @miscprint = '--  DEPLcontrol Insert for STAGE. Script from server: ''' + @@servername + ''''
	Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd


	Select @miscprint = '--  Created: '  + convert(varchar(30),getdate(),9)
	Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '--  Output file path is: ' + @outfile_path
	Print  @miscprint

	Select @miscprint = '--  Script is being sent to STAGE'
	Print  @miscprint

	Select @miscprint = ' '
	Print  @miscprint
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print '' ''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd


	-- Create script to insert into the dbo.request table
	Select @save_ProjectName = (select ProjectName from dbo.request where gears_id = @gears_id)
	Select @save_ProjectNum = (select ProjectNum from dbo.request where gears_id = @gears_id)
	Select @save_RequestDate = (select RequestDate from dbo.request where gears_id = @gears_id)
	Select @save_StartDate = (select StartDate from dbo.request where gears_id = @gears_id)
	Select @save_StartTime = (select StartTime from dbo.request where gears_id = @gears_id)
	Select @save_Environment = (select Environment from dbo.request where gears_id = @gears_id)
	Select @save_Notes = (select Notes from dbo.request where gears_id = @gears_id)
	If @save_Notes is null
	   begin
		Select @save_Notes = ' '
	   end
	Else
	   begin
		select @save_Notes = replace(@save_Notes, char(13)+char(10), ' ')
		select @save_Notes = replace(@save_Notes, char(13), ' ')
		select @save_Notes = replace(@save_Notes, char(10), ' ')
		select @save_Notes = left(@save_Notes, 50)
	   end

	Select @save_DBAapproved = (select DBAapproved from dbo.request where gears_id = @gears_id)
	Select @save_DBAapprover = (select DBAapprover from dbo.request where gears_id = @gears_id)
	Select @save_Status = (select Status from dbo.request where gears_id = @gears_id)
	Select @save_ModDate = (select ModDate from dbo.request where gears_id = @gears_id)

	Select @miscprint = 'if not exists (select 1 from DEPLcontrol.dbo.request where Gears_id = ' + convert(nvarchar(10), @gears_id) + ')'
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '   begin'
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '      INSERT INTO DEPLcontrol.dbo.request (Gears_id, ProjectName, ProjectNum, RequestDate, StartDate, StartTime, Environment, Notes, DBAapproved, DBAapprover, Status, ModDate)'
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '             VALUES (' + convert(nvarchar(10), @gears_id) + ''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + rtrim(@save_ProjectName) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + rtrim(@save_ProjectNum) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + convert(nvarchar(30), @save_RequestDate, 121) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + convert(nvarchar(30), @save_StartDate, 121) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + rtrim(@save_StartTime) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + rtrim(@save_Environment) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + rtrim(@save_Notes) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + rtrim(@save_DBAapproved) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + rtrim(@save_DBAapprover) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + rtrim(@save_Status) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + convert(nvarchar(30), @save_ModDate, 121) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    )'
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd




	-- Create script to insert into the dbo.request_detail table

	--  load the temp table
	delete from #temp_reqdet
	Insert into #temp_reqdet select reqdet_id from dbo.request_detail where gears_id = @gears_id and domain = 'stage'
	--select * from #temp_reqdet

	-- Loop through #temp_reqdet (request detail items)
	If (select count(*) from #temp_reqdet) > 0
	   begin
		start_reqdet:

		Select @save_reqdet_id = (select top 1 reqdet_id from #temp_reqdet order by reqdet_id)

		Select @save_DBname = (select DBname from dbo.request_detail where gears_id = @gears_id and reqdet_id = @save_reqdet_id)
		Select @save_APPLname = (select APPLname from dbo.request_detail where gears_id = @gears_id and reqdet_id = @save_reqdet_id)
		Select @save_SQLname = (select SQLname from dbo.request_detail where gears_id = @gears_id and reqdet_id = @save_reqdet_id)
		Select @save_BASEfolder = (select BASEfolder from dbo.request_detail where gears_id = @gears_id and reqdet_id = @save_reqdet_id)
		Select @save_Process = (select Process from dbo.request_detail where gears_id = @gears_id and reqdet_id = @save_reqdet_id)
		Select @save_ProcessType = (select ProcessType from dbo.request_detail where gears_id = @gears_id and reqdet_id = @save_reqdet_id)
		Select @save_ProcessDetail = (select ProcessDetail from dbo.request_detail where gears_id = @gears_id and reqdet_id = @save_reqdet_id)
		Select @save_Status = (select Status from dbo.request_detail where gears_id = @gears_id and reqdet_id = @save_reqdet_id)
		Select @save_ModDate = (select ModDate from dbo.request_detail where gears_id = @gears_id and reqdet_id = @save_reqdet_id)

		Select @miscprint = ' '
		--Print  @miscprint
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print '' ''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '      INSERT INTO DEPLcontrol.dbo.request_detail (Gears_id, Status, DBname, APPLname, SQLname, Domain, BASEfolder, Process, ProcessType, ProcessDetail, ModDate)'
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '             VALUES (' + convert(nvarchar(10), @gears_id) + ''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    ,''' + rtrim(@save_Status) + ''''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    ,''' + rtrim(@save_DBname) + ''''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    ,''' + rtrim(@save_APPLname) + ''''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    ,''' + rtrim(@save_SQLname) + ''''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    ,''STAGE'''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    ,''' + rtrim(@save_BASEfolder) + ''''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    ,''' + rtrim(@save_Process) + ''''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    ,''' + rtrim(@save_ProcessType) + ''''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    ,''' + rtrim(@save_ProcessDetail) + ''''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    ,''' + convert(nvarchar(30), @save_ModDate, 121) + ''''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    )'
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd


		Delete from #temp_reqdet where reqdet_id = @save_reqdet_id
		If (select count(*) from #temp_reqdet) > 0
		   begin
			goto start_reqdet
		   end
	   end


	--  complete the "IF" statement
	Select @miscprint = '   end'
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = 'go'
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = ' '
	--Print  @miscprint
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print '' ''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = ' '
	--Print  @miscprint
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print '' ''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	--  Send file to the stage central server
	Select @hold_source_path = '\\' + @save_servername + '\' + @save_servername2 + '_dbasql\dba_reports'	
	exec dbaadmin.dbo.dbasp_File_Transit @source_name = @outfile_name
		,@source_path = @hold_source_path
		,@target_env = 'STAGE'
		,@target_server = 'fresdbasql01'
		,@target_share = 'fresdbasql01_DEPLcontrol'


   end


--  If there are detail records for production, send that data to the central servers in the production domain
If exists (select 1 from dbo.request_detail where gears_id = @gears_id and domain = 'production')
   begin
	--  Create output file for stage
	Set @Hold_hhmmss = convert(varchar(8), getdate(), 8)
	Set @DateStmp = convert(char(8), getdate(), 112) + substring(@Hold_hhmmss, 1, 2) + substring(@Hold_hhmmss, 4, 2) + substring(@Hold_hhmmss, 7, 2) 

	Select @outfile_name = 'DEPLcontrolUpdate_PRODUCTION_' + @DateStmp + '.gsql'
	Select @outfile_path = '\\' + @save_servername + '\' + @save_servername2 + '_dbasql\dba_reports\' + @outfile_name
	Select @cmd = 'copy nul ' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd, no_output

	Select @miscprint = '--  DEPLcontrol Insert for PRODUCTION. Script from server: ''' + @@servername + ''''
	Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '--  Created: '  + convert(varchar(30),getdate(),9)
	Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '--  Output file path is: ' + @outfile_path
	Print  @miscprint

	Select @miscprint = '--  Script is being sent to PRODUCTION'
	Print  @miscprint

	Select @miscprint = ' '
	Print  @miscprint
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print '' ''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd


	-- Create script to insert into the dbo.request table
	Select @save_ProjectName = (select ProjectName from dbo.request where gears_id = @gears_id)
	Select @save_ProjectNum = (select ProjectNum from dbo.request where gears_id = @gears_id)
	Select @save_RequestDate = (select RequestDate from dbo.request where gears_id = @gears_id)
	Select @save_StartDate = (select StartDate from dbo.request where gears_id = @gears_id)
	Select @save_StartTime = (select StartTime from dbo.request where gears_id = @gears_id)
	Select @save_Environment = (select Environment from dbo.request where gears_id = @gears_id)
	Select @save_Notes = (select Notes from dbo.request where gears_id = @gears_id)
	If @save_Notes is null
	   begin
		Select @save_Notes = ' '
	   end
	Else
	   begin
		select @save_Notes = replace(@save_Notes, char(13)+char(10), ' ')
		select @save_Notes = replace(@save_Notes, char(13), ' ')
		select @save_Notes = replace(@save_Notes, char(10), ' ')
		select @save_Notes = left(@save_Notes, 50)
	   end
	Select @save_DBAapproved = (select DBAapproved from dbo.request where gears_id = @gears_id)
	Select @save_DBAapprover = (select DBAapprover from dbo.request where gears_id = @gears_id)
	Select @save_Status = (select Status from dbo.request where gears_id = @gears_id)
	Select @save_ModDate = (select ModDate from dbo.request where gears_id = @gears_id)

	Select @miscprint = 'if not exists (select 1 from DEPLcontrol.dbo.request where Gears_id = ' + convert(nvarchar(10), @gears_id) + ')'
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '   begin'
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '      INSERT INTO DEPLcontrol.dbo.request (Gears_id, ProjectName, ProjectNum, RequestDate, StartDate, StartTime, Environment, Notes, DBAapproved, DBAapprover, Status, ModDate)'
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '             VALUES (' + convert(nvarchar(10), @gears_id) + ''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + rtrim(@save_ProjectName) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + rtrim(@save_ProjectNum) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + convert(nvarchar(30), @save_RequestDate, 121) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + convert(nvarchar(30), @save_StartDate, 121) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + rtrim(@save_StartTime) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + rtrim(@save_Environment) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + rtrim(@save_Notes) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + rtrim(@save_DBAapproved) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + rtrim(@save_DBAapprover) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + rtrim(@save_Status) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    ,''' + convert(nvarchar(30), @save_ModDate, 121) + ''''
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = '                    )'
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd




	-- Create script to insert into the dbo.request_detail table

	--  load the temp table
	delete from #temp_reqdet
	Insert into #temp_reqdet select reqdet_id from dbo.request_detail where gears_id = @gears_id and domain = 'production'
	--select * from #temp_reqdet

	-- Loop through #temp_reqdet (request detail items)
	If (select count(*) from #temp_reqdet) > 0
	   begin
		start_reqdet2:

		Select @save_reqdet_id = (select top 1 reqdet_id from #temp_reqdet order by reqdet_id)

		Select @save_Status = (select Status from dbo.request_detail where gears_id = @gears_id and reqdet_id = @save_reqdet_id)
		Select @save_DBname = (select DBname from dbo.request_detail where gears_id = @gears_id and reqdet_id = @save_reqdet_id)
		Select @save_APPLname = (select APPLname from dbo.request_detail where gears_id = @gears_id and reqdet_id = @save_reqdet_id)
		Select @save_SQLname = (select SQLname from dbo.request_detail where gears_id = @gears_id and reqdet_id = @save_reqdet_id)
		Select @save_BASEfolder = (select BASEfolder from dbo.request_detail where gears_id = @gears_id and reqdet_id = @save_reqdet_id)
		Select @save_Process = (select Process from dbo.request_detail where gears_id = @gears_id and reqdet_id = @save_reqdet_id)
		Select @save_ProcessType = (select ProcessType from dbo.request_detail where gears_id = @gears_id and reqdet_id = @save_reqdet_id)
		Select @save_ProcessDetail = (select ProcessDetail from dbo.request_detail where gears_id = @gears_id and reqdet_id = @save_reqdet_id)
		Select @save_ModDate = (select ModDate from dbo.request_detail where gears_id = @gears_id and reqdet_id = @save_reqdet_id)

		Select @miscprint = ' '
		--Print  @miscprint
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print '' ''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '      INSERT INTO DEPLcontrol.dbo.request_detail (Gears_id, Status, DBname, APPLname, SQLname, Domain, BASEfolder, Process, ProcessType, ProcessDetail, ModDate)'
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '             VALUES (' + convert(nvarchar(10), @gears_id) + ''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    ,''' + rtrim(@save_Status) + ''''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    ,''' + rtrim(@save_DBname) + ''''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    ,''' + rtrim(@save_APPLname) + ''''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    ,''' + rtrim(@save_SQLname) + ''''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    ,''PRODUCTION'''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    ,''' + rtrim(@save_BASEfolder) + ''''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    ,''' + rtrim(@save_Process) + ''''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    ,''' + rtrim(@save_ProcessType) + ''''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    ,''' + rtrim(@save_ProcessDetail) + ''''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    ,''' + convert(nvarchar(30), @save_ModDate, 121) + ''''
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd

		Select @miscprint = '                    )'
		--Print  @miscprint
		Select @miscprint = replace(@miscprint, '''', '''''')
		Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
		EXEC master.sys.xp_cmdshell @cmd


		Delete from #temp_reqdet where reqdet_id = @save_reqdet_id
		If (select count(*) from #temp_reqdet) > 0
		   begin
			goto start_reqdet2
		   end
	   end


	--  complete the "IF" statement
	Select @miscprint = '   end'
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = 'go'
	--Print  @miscprint
	Select @miscprint = replace(@miscprint, '''', '''''')
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print ''' + @miscprint + '''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = ' '
	--Print  @miscprint
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print '' ''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd

	Select @miscprint = ' '
	--Print  @miscprint
	Select @cmd = 'sqlcmd -S' + @@servername + ' -w265 -u -Q"print '' ''" -E >>' + @outfile_path
	EXEC master.sys.xp_cmdshell @cmd


	--  Send file to the production central server
	Select @hold_source_path = '\\' + @save_servername + '\' + @save_servername2 + '_dbasql\dba_reports'	
	exec dbaadmin.dbo.dbasp_File_Transit @source_name = @outfile_name
		,@source_path = @hold_source_path
		,@target_env = 'PRODUCTION'
		,@target_server = 'seaexsqlmail'
		,@target_share = 'seaexsqlmail_DEPLcontrol'

   end



-----------------  Finalizations  ------------------

label99:


--  Print out sample exection of this sproc for specific gears_id
If @update_flag = 'n' and @prodstage_flag = 'y'
   begin
	exec DEPLcontrol.dbo.dpsp_Status @report_only = 'y'

	Print  ' '
	Print  ' '
	Select @miscprint = '--Here is a sample execute command for this sproc:'
	Print  @miscprint
	Print  ' '
	Select @miscprint = '--Approve Gears Request for Deployment in stage or production:'
	Print  @miscprint
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_Approve @gears_id = 12345'
	Print  @miscprint
	Select @miscprint = '                                 ,@runtype = ''manual''  --''auto'''
	Print  @miscprint
	Select @miscprint = '                                 --,@DBA_override = ''y'''
	Print  @miscprint
	Print  ' '
   end
Else If @update_flag = 'n' and @auto <> 'y'
   begin 
	If @gears_id is null
	   begin
		exec DEPLcontrol.dbo.dpsp_Status @report_only = 'y'

		Print  ' '
		Print  ' '
		Select @miscprint = '--Here is a sample execute command for this sproc:'
		Print  @miscprint
		Print  ' '
		Select @miscprint = '--Approve Gears Request for Deployment:'
		Print  @miscprint
		Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_Approve @gears_id = 12345'
		Print  @miscprint
		Select @miscprint = '                                 --,@runtype = ''manual''  --''auto'''
		Print  @miscprint
		Select @miscprint = '                                 --,@DBA_override = ''y'''
		Print  @miscprint
		Print  ' '
	   end
	Else
	   begin
		exec DEPLcontrol.dbo.dpsp_Status @gears_id = @gears_id, @report_only = 'y'

		Select @save_detail_id = (select top 1 reqdet_id from dbo.Request_detail where Gears_id = @gears_id and ProcessType like '%Override%')
		Select @save_DBname = (select top 1 DBname from dbo.Request_detail where reqdet_id = @save_detail_id)
		Select @save_StartDate = (select StartDate from dbo.Request where Gears_id = @gears_id)
		Select @save_StartTime = (select StartTime from dbo.Request where Gears_id = @gears_id)
		Select @save_StartTime = replace(@save_StartTime, 'z', '')
		Select @save_Start = convert(char(8), @save_StartDate, 112) + ' ' + rtrim(@save_StartTime)

		Print  ' '
		Print  ' '
		Select @miscprint = '--Here is a sample execute command for this sproc:'
		Print  @miscprint
		Print  ' '
		Select @miscprint = '--Approve Gears Request for Deployment:'
		Print  @miscprint
		Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_Approve @gears_id = 12345'
		Print  @miscprint
		Select @miscprint = '                                 --,@runtype = ''manual''  --''auto'''
		Print  @miscprint
		Select @miscprint = '                                 --,@DBA_override = ''y'''
		Print  @miscprint
		Print  ' '
		Print  ' '
		Print  ' '
		Select @miscprint = '--Here are sample execute commands for the dbo.dpsp_Update sproc:'
		Print  @miscprint
		Print  ' '
		Select @miscprint = '--Update Request Detail for a speicif Gears ID:'
		Print  @miscprint
		Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_update @gears_id = ' + convert(nvarchar(20), @gears_id)
		Print  @miscprint
		Select @miscprint = '                                ,@detail_id = ' + convert(nvarchar(20), @save_detail_id)
		Print  @miscprint
		Select @miscprint = '                                ,@DBname = ''' + @save_DBname + ''''
		Print  @miscprint
		Select @miscprint = '                                ,@ProcessType = ''DBA-ok'''
		Print  @miscprint
		Print  ' '
		Select @miscprint = '--Cancel Request Detail for a speicif Gears ID:'
		Print  @miscprint
		Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_update @gears_id = ' + convert(nvarchar(20), @gears_id)
		Print  @miscprint
		Select @miscprint = '                                ,@detail_id = ' + convert(nvarchar(20), @save_detail_id)
		Print  @miscprint
		Select @miscprint = '                                ,@DBname = ''' + @save_DBname + ''''
		Print  @miscprint
		Select @miscprint = '                                ,@ProcessType = ''DBA-cancelled'''
		Print  @miscprint
		Select @miscprint = '                                ,@status = ''cancelled'''
		Print  @miscprint
		Print  ' '
		Select @miscprint = '--Update StartTime for a speicif Gears ID:'
		Print  @miscprint
		Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_update @gears_id = ' + convert(nvarchar(20), @gears_id)
		Print  @miscprint
		Select @miscprint = '                                ,@start_dt = ''' + @save_Start + ''''
		Print  @miscprint
		Print  ' '

	   end

   end
Else If @auto <> 'y'
   begin
	Select @cmd = 'DEPLcontrol.dbo.dpsp_Status @gears_id = ' + convert(nvarchar(10), @gears_id) + ', @report_only = ''y'''
	execute sp_executesql @cmd
   end


drop table #temp_reqdet




GO
