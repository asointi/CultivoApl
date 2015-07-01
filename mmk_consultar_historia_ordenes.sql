set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[mmk_consultar_historia_ordenes] 

@fecha_inicial datetime,
@fecha_final datetime

as

select carrier_code, 
carrier_name, 
customer_code,
customer_name, 
po_number, 
miami_ship_date, 
num_sol, 
lid_code, 
lid_name, 
M_pieces, 
code, 
ethyblock_sachet, 
box_name, 
M_fulls, 
flower_code, 
flower_name, 
variety_code, 
variety_name, 
grade_code, 
grade_name, 
farm_code, 
farm_name, 
M_requested_pieces, 
flight_date, 
request_date,
M_farm_price, 
shipped_observation, 
M_confirmed_pieces, 
confirmation_observation, 
pepr, 
bunches, 
food_name
from PivoteMM
where miami_ship_date between
@fecha_inicial and @fecha_final