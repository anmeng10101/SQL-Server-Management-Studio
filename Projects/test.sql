use [KeywordLookup]
go

CREATE PARTITION FUNCTION [_dta_pf__9987](int) AS RANGE RIGHT FOR VALUES (0)
go

CREATE PARTITION SCHEME [_dta_ps__4364] AS PARTITION [_dta_pf__9987] TO ([PRIMARY], [PRIMARY])
go

DROP INDEX [PK_vwPreferredSynonym] ON [dbo].[vwPreferredSynonym] WITH ( ONLINE = OFF )
go

DROP INDEX [IXNvwPreferredSynonym_SynTermSyn] ON [dbo].[vwPreferredSynonym] WITH ( ONLINE = OFF )
go

DROP INDEX [IXNvwPreferredSynonym_TermTermSyn] ON [dbo].[vwPreferredSynonym] WITH ( ONLINE = OFF )
go

DROP INDEX [IXNvwPreferredSynonym_TermSynTerm] ON [dbo].[vwPreferredSynonym] WITH ( ONLINE = OFF )
go

DROP INDEX [PK_vwTermSynonymEN-US] ON [dbo].[vwTermSynonymEN-US] WITH ( ONLINE = OFF )
go

DROP INDEX [IXNvwTermSynonymEN-US_SynTermSyn] ON [dbo].[vwTermSynonymEN-US] WITH ( ONLINE = OFF )
go

DROP INDEX [IXNvwTermSynonymEN-US_TermTermSyn] ON [dbo].[vwTermSynonymEN-US] WITH ( ONLINE = OFF )
go

DROP INDEX [IXNvwTermSynonymEN-US_TermSynTerm] ON [dbo].[vwTermSynonymEN-US] WITH ( ONLINE = OFF )
go

DROP INDEX [PK_vwTermSynonymEN-GB] ON [dbo].[vwTermSynonymEN-GB] WITH ( ONLINE = OFF )
go

DROP INDEX [IXNvwTermSynonymEN-GB_SynTermSyn] ON [dbo].[vwTermSynonymEN-GB] WITH ( ONLINE = OFF )
go

DROP INDEX [IXNvwTermSynonymEN-GB_TermTermSyn] ON [dbo].[vwTermSynonymEN-GB] WITH ( ONLINE = OFF )
go

DROP INDEX [IXNvwTermSynonymEN-GB_TermSynTerm] ON [dbo].[vwTermSynonymEN-GB] WITH ( ONLINE = OFF )
go

DROP INDEX [PK_vwPreferredSynonymEN-US] ON [dbo].[vwPreferredSynonymEN-US] WITH ( ONLINE = OFF )
go

DROP INDEX [IXNvwPreferredSynonymEN-US_SynTermSyn] ON [dbo].[vwPreferredSynonymEN-US] WITH ( ONLINE = OFF )
go

DROP INDEX [IXNvwPreferredSynonymEN-US_TermSynTerm] ON [dbo].[vwPreferredSynonymEN-US] WITH ( ONLINE = OFF )
go

DROP INDEX [IXNvwPreferredSynonymEN-US_TermTermSyn] ON [dbo].[vwPreferredSynonymEN-US] WITH ( ONLINE = OFF )
go

DROP INDEX [PK_vwPreferredSynonymEN-GB] ON [dbo].[vwPreferredSynonymEN-GB] WITH ( ONLINE = OFF )
go

DROP INDEX [IXNvwPreferredSynonymEN-GB_SynTermSyn] ON [dbo].[vwPreferredSynonymEN-GB] WITH ( ONLINE = OFF )
go

DROP INDEX [IXNvwPreferredSynonymEN-GB_TermSynTerm] ON [dbo].[vwPreferredSynonymEN-GB] WITH ( ONLINE = OFF )
go

DROP INDEX [IXNvwPreferredSynonymEN-GB_TermTermSyn] ON [dbo].[vwPreferredSynonymEN-GB] WITH ( ONLINE = OFF )
go

DROP INDEX [IXNTermSynonym_SynTermTermSynID] ON [dbo].[TermSynonym] WITH ( ONLINE = OFF )
go

DROP INDEX [IXNTermSynonym_SynTermSynID] ON [dbo].[TermSynonym] WITH ( ONLINE = OFF )
go

DROP INDEX [IXNTermSynonym_TermTermSyn] ON [dbo].[TermSynonym] WITH ( ONLINE = OFF )
go

CREATE NONCLUSTERED INDEX [_dta_index_TermSynonym_8_597577167_13149776_K5_K4_K2_K3] ON [dbo].[TermSynonym] 
(
	[LanguageID] ASC,
	[IsPreferred] ASC,
	[TermID] ASC,
	[SynonymText] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [_dta_ps__4364]([TermID])
go

CREATE STATISTICS [_dta_stat_597577167_2_5] ON [dbo].[TermSynonym]([TermID], [LanguageID])
go

CREATE STATISTICS [_dta_stat_597577167_3_4_2] ON [dbo].[TermSynonym]([SynonymText], [IsPreferred], [TermID])
go

CREATE STATISTICS [_dta_stat_597577167_2_4_5_3] ON [dbo].[TermSynonym]([TermID], [IsPreferred], [LanguageID], [SynonymText])
go

