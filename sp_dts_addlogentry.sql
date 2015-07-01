/****** Object:  StoredProcedure [dbo].[sp_dts_addlogentry]    Script Date: 11/13/2007 13:06:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_dts_addlogentry]  
@event sysname,  @computer nvarchar(128),  @operator nvarchar(128),  @source nvarchar(1024),  @sourceid uniqueidentifier,  @executionid uniqueidentifier,  @starttime datetime,  @endtime datetime,  @datacode int,  @databytes image,  @message nvarchar(2048)AS  INSERT INTO sysdtslog90 (      event,      computer,      operator,      source,      sourceid,      executionid,      starttime,      endtime,      datacode,      databytes,      message )  VALUES (      @event,      @computer,      @operator,      @source,      @sourceid,      @executionid,      @starttime,      @endtime,      @datacode,      @databytes,      @message )  RETURN 0