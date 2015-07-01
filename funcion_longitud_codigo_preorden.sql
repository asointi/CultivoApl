set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create FUNCTION [dbo].[longitud_codigo_preorden] (@codigo int)

RETURNS nvarchar(4)
WITH EXECUTE AS CALLER

AS
BEGIN
	declare @codigo_char nvarchar(4),
	@longitud int

	set @codigo_char = @codigo

	select @longitud = len(@codigo_char)

	while(@longitud < 4)
	begin
		set @codigo_char = '0' + @codigo_char
		set @longitud = len(@codigo_char)
	end

	RETURN(@codigo_char);
END;


