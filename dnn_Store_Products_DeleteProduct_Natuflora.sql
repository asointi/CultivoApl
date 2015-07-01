set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


create PROCEDURE [dbo].[dnn_Store_Products_DeleteProduct_Natuflora]

@ProductID int

AS

delete from  dbo.Store_Products 
WHERE ProductID = @ProductID
	

