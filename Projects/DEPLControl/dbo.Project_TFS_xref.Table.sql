USE [DEPLcontrol]
GO
/****** Object:  Table [dbo].[Project_TFS_xref]    Script Date: 10/4/2013 11:02:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Project_TFS_xref](
	[ptx_id] [int] IDENTITY(1,1) NOT NULL,
	[active] [char](1) NOT NULL,
	[Projectname] [sysname] NOT NULL,
	[Projectver] [sysname] NOT NULL,
	[Projectcodeline] [sysname] NOT NULL,
	[TFSservername] [sysname] NOT NULL,
	[TFSteamproject] [sysname] NOT NULL,
	[TFSdatabasepath] [sysname] NOT NULL,
	[createdate] [datetime] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
