USE [DEPLcontrol]
GO
/****** Object:  Table [dbo].[control_HL]    Script Date: 10/4/2013 11:02:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[control_HL](
	[chl_id] [int] IDENTITY(1,1) NOT NULL,
	[Gears_id] [int] NOT NULL,
	[SQLname] [sysname] NOT NULL,
	[domain] [sysname] NOT NULL,
	[HandShake_Status] [sysname] NULL,
	[HandShake_sql] [nvarchar](5) NULL,
	[HandShake_agent] [nvarchar](5) NULL,
	[HandShake_DEPLjobs] [nvarchar](5) NULL,
	[HandShake_start] [datetime] NULL,
	[HandShake_complete] [datetime] NULL,
	[Setup_Status] [sysname] NULL,
	[Setup_start] [datetime] NULL,
	[Setup_complete] [datetime] NULL,
	[Restore_Status] [sysname] NULL,
	[Restore_start] [datetime] NULL,
	[Restore_complete] [datetime] NULL,
	[Deploy_Status] [sysname] NULL,
	[Deploy_start] [datetime] NULL,
	[Deploy_complete] [datetime] NULL,
	[End_Status] [sysname] NULL,
	[End_start] [datetime] NULL,
	[End_complete] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_clust_control_HL]    Script Date: 10/4/2013 11:02:05 AM ******/
CREATE NONCLUSTERED INDEX [IX_clust_control_HL] ON [dbo].[control_HL]
(
	[Gears_id] ASC,
	[SQLname] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
