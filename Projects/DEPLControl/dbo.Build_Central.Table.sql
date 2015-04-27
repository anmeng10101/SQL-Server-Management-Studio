USE [DEPLcontrol]
GO
/****** Object:  Table [dbo].[Build_Central]    Script Date: 10/4/2013 11:02:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Build_Central](
	[bc_id] [int] IDENTITY(1,1) NOT NULL,
	[Gears_id] [int] NOT NULL,
	[SQLname] [sysname] NOT NULL,
	[DBName] [sysname] NOT NULL,
	[BuildLabel] [sysname] NOT NULL,
	[BuildDate] [datetime] NOT NULL,
	[BuildNotes] [varchar](255) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
