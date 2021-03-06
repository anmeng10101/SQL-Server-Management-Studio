USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_CreateMissingSingleColumnStats]    Script Date: 08/30/2012 14:06:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_CreateMissingSingleColumnStats]
AS
BEGIN
	SET	TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET	NOCOUNT		ON
	SET	ANSI_WARNINGS	ON
		
	declare	@Cmd		nvarchar(max)
		,@Msg		nvarchar(512)
		,@TableName	nvarchar(256)
		,@ColumnName	nvarchar(128)

	DECLARE	@MissingStats	TABLE
				(
				 [TableName]	SYSNAME
				,[ColumnName]	SYSNAME
				)
		
	;WITH		StatsList
			AS
			(
			select		s.object_id
					,s.stats_id
					,sc.column_id
			from		sys.stats		s WITH(NOLOCK)
			join		sys.stats_columns	sc WITH(NOLOCK)
				on	s.object_id		= sc.object_id
				and	s.stats_id		= sc.stats_id
			where		sc.stats_column_id	= 1	--only look at stats where the statistic is on the first column
			)
	INSERT INTO	@MissingStats				
	SELECT		'['+sch.name+'].['+object_name(c.object_id)+']' as TableName
			,c.name as ColumnName
	FROM		sys.columns c WITH(NOLOCK)
	JOIN		sys.objects o WITH(NOLOCK)
		ON	c.object_id		= o.object_id
		AND	(
			o.type = 'U' 
		  or	(
			o.type = 'V' 
		    and	objectproperty(o.object_id,'IsIndexed')=1
			)
			)
	JOIN		sys.schemas sch WITH(NOLOCK)
		ON	sch.schema_id	= o.schema_id
	LEFT JOIN	StatsList s
		on	c.object_id = s.object_id
		and	c.column_id = s.column_id
	where		s.stats_id is null			--only find columns where there are no stats
		and	c.user_type_id not in (241)		-- ignore XML columns


	DECLARE statsCursor CURSOR LOCAL READ_ONLY
	FOR
	SELECT		TableName
			,ColumnName
	FROM		@MissingStats		

	OPEN StatsCursor
	FETCH NEXT FROM StatsCursor INTO @TableName,@ColumnName
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN

			set @Cmd='create statistics [CustomStat_'+REPLACE(@ColumnName,' ','_')+'] on '+@TableName + '(['+@ColumnName+'])'
			set @Msg='-- creating stats on '+@TableName+'(['+@ColumnName+'])'

			print @Msg
			print @Cmd
			exec (@Cmd)

		END
		FETCH NEXT FROM StatsCursor INTO @TableName,@ColumnName
	END
	CLOSE StatsCursor
	DEALLOCATE StatsCursor
END
