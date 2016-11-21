USE [BD_CAMPANIAS]
GO
/****** Object:  StoredProcedure [dbo].[sp_PreAprobados_01FusionRiesgoUniverso]    Script Date: 21/11/2016 11:40:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec sp_PreAprobados_01FusionRiesgoUniverso 201611
ALTER PROCEDURE [dbo].[sp_PreAprobados_01FusionRiesgoUniverso]
	-- Add the parameters for the stored procedure here
	@Periodo int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @fechaLicencia varchar(10) =substring((Select CONVERT(varchar,SYSDATETIME(),126)),1,7)+'-01'


	if OBJECT_ID('BD_CAMPANIAS..TabCmp_AfiliadoLicencia') is not null Drop Table TabCmp_AfiliadoLicencia
	select Afiliado_Rut 
	into TabCmp_AfiliadoLicencia
	from BD_ODS..TabLic_Licencia 
	where substring(convert(varchar,Licencia_fFin,126),1,10) >= @fechaLicencia
	
	if OBJECT_ID('BD_CAMPANIAS..TabCmp_MaestraCreditos') is not null Drop Table TabCmp_Maestra_Creditos
   select 
	 Rut_Afiliado
	,SUM(monto_total_cuota) SumaCoutas
	,MAX(Fecha_Colocacion) max_fecha_desembolso
	,COUNT(Folio_Antig_Credito) cantidad_creditos
	,Max(Meses_Morosos) Meses_Morosos
	,case when sum(K_Efectivo)<>sum(K_Calculado) and sum(K_Calculado) > 0 then sum(K_Calculado) else  sum(K_Efectivo) end Capital_adeudado
	,case when MAX(castigo)='' then 0 when MAX(castigo)='X' then 1 end ind_castigo
	into TabCmp_Maestra_Creditos
	from BD_ODS..TabCred_MaestroCreditos 
	where Periodo = (select MAX(periodo) from BD_ODS..TabCred_MaestroCreditos) 
	and Estado=30 
	and Tipo_Producto in ('C_SOCIAL', 'C_EDUCA' )  -- C_EXTINC, CTA_CTE_EM
	and Desembolso<>'NO Existe'
	and Tipo_Financiamiento not in ('Intermediado','Intermediado')
	and (case when K_calculado<>K_Efectivo and K_Calculado>0 then K_Calculado else K_Efectivo end)>0
	group by Rut_Afiliado



	if OBJECT_ID('BD_CAMPANIAS..TabCmp_MaestraCreditosMorosos') is not null Drop Table TabCmp_MaestraCreditosMorosos
	select 
	 Rut_Afiliado
	,SUM(monto_total_cuota) SumaCoutas
	,MAX(Fecha_Colocacion) max_fecha_desembolso
	,COUNT(Folio_Antig_Credito) cantidad_creditos
	,Max(Meses_Morosos) Meses_Morosos
	,case when sum(K_Efectivo)<>sum(K_Calculado) and sum(K_Calculado) > 0 then sum(K_Calculado) else  sum(K_Efectivo) end Capital_adeudado
	,case when MAX(castigo)='' then 0 when MAX(castigo)='X' then 1 end ind_castigo
	into TabCmp_MaestraCreditosMorosos
	from BD_ODS..TabCred_MaestroCreditos 
	where Periodo = (select MAX(periodo) from BD_ODS..TabCred_MaestroCreditos) 
	and Estado=30 
	and Tipo_Producto in ('C_SOCIAL', 'C_EDUCA' )  -- C_EXTINC, CTA_CTE_EM
	and Desembolso<>'NO Existe'
	and Tipo_Financiamiento not in ('Intermediado','Intermediado')
	and (case when K_calculado<>K_Efectivo and K_Calculado>0 then K_Calculado else K_Efectivo end)>0
	group by Rut_Afiliado
	having MAX(Meses_Morosos)>1 OR MAX(castigo)='X'



	/*Sin Credito*/
	UPDATE TabCmp_UniversoAfiliados 
	SET Monto_preaprobado = convert(NUMERIC, (
		case 
				when Segmento in ('Publicos') and Antiguedad_en_Meses <= 24 then ((round((MontoRenta*0.75),0)*0.25))*24
				when Segmento in ('Publicos') and Antiguedad_en_Meses > 24  then ((round((MontoRenta*0.75),0)*0.25))*60
				when Segmento in ('Privados') then ((round((MontoRenta*0.75),0)*0.25))*60 
	  end
	))
	WHERE Afiliado_Rut not in (select Rut_Afiliado from TabCmp_Maestra_Creditos)
	AND Periodo = @Periodo
	and RiesgoMaxPreAprobado is not null



	UPDATE TabCmp_UniversoAfiliados 
	SET Monto_preaprobado = (
				case 
						when Segmento <> 'Pensionados' and Monto_preaprobado > (round((MontoRenta*0.75),0)*8) then (round((MontoRenta*0.75),0)*8)
						when Segmento <> 'Pensionados' and Monto_preaprobado < (round((MontoRenta*0.75),0)*8) then Monto_preaprobado
						when Segmento = 'Pensionados' then isNull(dbo.fn_calculoMontoPreAprobadoPensionado(PensionadoFFAA,MontoPension,0,0),0)
				end)
	WHERE Afiliado_Rut not in (select Rut_Afiliado from TabCmp_Maestra_Creditos)
	AND Periodo = @Periodo
	and RiesgoMaxPreAprobado is not null


	/*Con Credito*/
	UPDATE a
	SET Monto_preaprobado = (
			case 
				when Segmento in ('Publicos') and Antiguedad_en_Meses <= 24 then ((round((MontoRenta*0.75),0)*0.25)-b.SumaCoutas)*24
				when Segmento in ('Publicos') and Antiguedad_en_Meses > 24  then ((round((MontoRenta*0.75),0)*0.25)-b.SumaCoutas)*60
				when Segmento in ('Privados') then ((round((MontoRenta*0.75),0)*0.25)-b.SumaCoutas)*60 
			end)
	FROM		TabCmp_UniversoAfiliados a
	LEFT JOIN	TabCmp_Maestra_Creditos b on a.afiliado_rut=b.Rut_Afiliado
	WHERE Afiliado_Rut in (select Rut_Afiliado from TabCmp_Maestra_Creditos)
	AND Periodo = @Periodo
	and RiesgoMaxPreAprobado is not null



	UPDATE a
	SET Monto_preaprobado = (
			case 
				when Segmento <> 'Pensionados' and Monto_preaprobado+Capital_adeudado > (round((MontoRenta*0.75),0)*8) then (round((MontoRenta*0.75),0)*8)-Capital_adeudado
				when Segmento <> 'Pensionados' and Monto_preaprobado+Capital_adeudado < (round((MontoRenta*0.75),0)*8) then Monto_preaprobado
				when Segmento = 'Pensionados' then isNUll(dbo.fn_calculoMontoPreAprobadoPensionado(PensionadoFFAA,MontoPension,SumaCoutas,capital_adeudado),0)
		end)
	FROM TabCmp_UniversoAfiliados a
	left join TabCmp_Maestra_Creditos b on a.afiliado_rut=b.Rut_Afiliado
	WHERE Afiliado_Rut in (select Rut_Afiliado from TabCmp_Maestra_Creditos)
	AND Periodo = @Periodo
	and RiesgoMaxPreAprobado is not null




	/* PreAprobado Final */
	UPDATE TabCmp_UniversoAfiliados
		SET
			PreAprobadoFinal = (
				CASE
					when Monto_preaprobado < RiesgoMaxPreAprobado  then Monto_preaprobado 
					when Monto_preaprobado >= RiesgoMaxPreAprobado  then RiesgoMaxPreAprobado
				END)
		WHERE Periodo=@Periodo 
		and RiesgoMaxPreAprobado is not null
		
		UPDATE TabCmp_UniversoAfiliados
		SET PreAprobadoFinal = (CASE 
									WHEN PreAprobadoFinal > 25000000 THEN 25000000
									ELSE PreAprobadoFinal
								 END)
		where Periodo=@Periodo 
		and RiesgoMaxPreAprobado > 0
		and RiesgoMaxPreAprobado is not null

END
