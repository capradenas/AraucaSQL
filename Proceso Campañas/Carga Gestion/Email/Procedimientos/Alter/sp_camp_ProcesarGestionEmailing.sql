USE [BD_CAMPANIAS]
GO
/****** Object:  StoredProcedure [dbo].[sp_camp_ProcesarGestionEmailing]    Script Date: 18/11/2016 14:42:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[sp_camp_ProcesarGestionEmailing](
	@nomina_id INT, @orden_envio INT, @fecha_envio date
)
AS
BEGIN
	SET NOCOUNT ON;

	
-----------------------------------------------------------------------------
----- Gestion de Emails desde gurú. Cärlös								-----	
-----------------------------------------------------------------------------
-----	DECLARE @nomina_id INT = 10										-----
-----	DECLARE @orden_envio INT = 4									-----
-----	DECLARE @fecha_envio date = '2016-10-26'						-----
-----------------------------------------------------------------------------

	--Aperturas y Desuscritos 
	select distinct @nomina_id as nomina, 
				CASE WHEN CHARINDEX('-',x.afiliado_id) > 0 THEN Left(x.afiliado_id,LEN(x.afiliado_id)-2) ELSE x.afiliado_id END afiliado_id,
				CONVERT(VARCHAR(10),CAST(x.Fecha as datetime) ,112) FechaAccion, 
				1 Abierto, 
				0 Desuscrito, 
				0 Rebotado,
				0 Click
	into #tmp_GesEmail
	from BD_CARGAS..TabCmp_CorreoAperturas x
	WHERE CASE WHEN CHARINDEX('-',x.afiliado_id) > 0 THEN Left(x.afiliado_id,LEN(x.afiliado_id)-2) ELSE x.afiliado_id END not in (select ges_afiliado_rut from BD_CAMPANIAS..TabCmp_GestionCamp where ges_nomina = @nomina_id)
	AND CASE WHEN CHARINDEX('-',x.afiliado_id) > 0 THEN Left(x.afiliado_id,LEN(x.afiliado_id)-2) ELSE x.afiliado_id END in (select nomid_rut_afiliado from TabCmp_NominasDetalle where nomid_nomi_id = @nomina_id)


	 /*Desuscritos*/
	update #tmp_GesEmail set Desuscrito=1
	where afiliado_id in (
	select distinct (CASE WHEN CHARINDEX('-',y.afiliado_id) > 0 THEN Left(y.afiliado_id,LEN(y.afiliado_id)-2) ELSE y.afiliado_id END)
	from BD_CARGAS..TabCmp_CorreoDesuscritos y
	)

	/*Clicks*/
	update #tmp_GesEmail set Click=1
	where afiliado_id in (
	select distinct (CASE WHEN CHARINDEX('-',y.afiliado_id) > 0 THEN Left(y.afiliado_id,LEN(y.afiliado_id)-2) ELSE y.afiliado_id END)
	from BD_CARGAS..TabCmp_CorreoClicks y
	)

	/*Volcado de datos*/
	insert into BD_CAMPANIAS..TabCmp_GestionCamp
	select nomina, afiliado_id, MIN(FechaAccion) FechaAccion, Abierto, Desuscrito, Rebotado,Click, @orden_envio, @fecha_envio
	from #tmp_GesEmail
	group by nomina, afiliado_id,  Abierto, Desuscrito, Rebotado, Click

	/*Limpiar*/
	drop table #tmp_GesEmail

	--REBOTADOS
	insert into BD_CAMPANIAS..TabCmp_GestionCamp
	select distinct  @nomina_id as nomina, CASE WHEN CHARINDEX('-',afiliado_id) > 0 THEN Left(afiliado_id,LEN(afiliado_id)-2) ELSE afiliado_id END afiliado_id,  CONVERT(VARCHAR(10),CAST(Fecha as datetime),112) Fecha, 0 Abierto, 0 Desuscrito, 1 Rebotado, 0 Click, @orden_envio, @fecha_envio
	from BD_CARGAS..TabCmp_CorreoRebotados
	where CASE WHEN CHARINDEX('-',afiliado_id) > 0 THEN Left(afiliado_id,LEN(afiliado_id)-2) ELSE afiliado_id END not in (select ges_afiliado_rut from BD_CAMPANIAS..TabCmp_GestionCamp where ges_nomina = @nomina_id and ges_rebotado = 1)


	select * 
	from BD_CAMPANIAS..TabCmp_GestionCamp
	where ges_nomina = @nomina_id
	and ges_envio = @orden_envio
	and ges_fecha_envio = @fecha_envio

END
