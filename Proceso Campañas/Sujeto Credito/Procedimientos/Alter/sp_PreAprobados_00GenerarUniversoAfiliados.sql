USE [BD_CAMPANIAS]
GO
/****** Object:  StoredProcedure [dbo].[sp_PreAprobados_00GenerarUniversoAfiliados]    Script Date: 21/11/2016 15:41:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[sp_PreAprobados_00GenerarUniversoAfiliados]
	@Periodo INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @SQL_STMT VARCHAR(MAX)

	/*Universo de Afiliados*/
	insert into TabCmp_UniversoAfiliados
	Select 
		 @Periodo as Periodo
		,Afiliado_Rut 
		,Afiliado_Dv
		,Nombre
		,Apellido
		,Empresa_Rut
		,Empresa_Dv		
		,EmpresaNombre Empresa
		,ClaRiesgoEmpresa
		,Holding
		,Celular
		,Telefono1
		,Telefono2
		,Email
		,MontoPension 
		,MontoRenta
		,0 Monto_preaprobado
		,AntiguedadCajaAfiMeses Antiguedad_en_Meses
		,LicMedicaVigente
		,CreditosVigentes
		,CredVig_Meses_Morosos
		,CredVig_MontoCuota
		,EsPensionado
		,EsPrivado
		,EsPublico
		,Contacto
		,Case 
			when EmpresaEsPensionado=0 and (EmpresaNombre like '%corpo%' or EmpresaNombre like '%corp%') then 'Publicos'
            when EmpresaEsPensionado=0 and (EmpresaNombre like '%municip%' or EmpresaNombre like '%mun.%' 
                or EmpresaNombre like '%munic.%' 
                or EmpresaNombre like '%munin.%') then 'Publicos'
            when EmpresaEsPensionado=0 and Empresa_Rut in(65321890,61930600,60902063,65473570,65199980) then 'Publicos'
			When EmpresaEsPublico=1 Then 'Publicos'
			When EmpresaEsPrivado=1 Then 'Privados'
			when EmpresaEsPensionado=1 then 'Pensionados'
         End Segmento
		,FechaNacimiento
		,Edad
		,PensionadoFFAA
		,EmpresaEsPensionado
		,EmpresaEsPublico
		,EmpresaEsPrivado
		,Sexo
		,null
		,null
		,null
		,null
		,null
		From bd_ods..TabAfi_AfiliadoTablon


	/*Universo de Afiliados Intercajas*/
	insert into BD_CAMPANIAS..TabCmp_UniversoAfiliados_Intercaja
	select @Periodo as Periodo,	
		y.Afiliado_Rut, 
		y.Afiliado_Dv, 
		y.Nombre,
		y.Apellido,
		y.Empresa_Rut, 
		y.Empresa_Dv, 
		y.EmpresaNombre, 
		SUM(x.MONTODEUDA) Monto_Intercaja, 
		count(*) CantidadCreditos,
		y.MontoRenta, 
		y.MontoPension,
		y.AntiguedadCajaAfiMeses antiguedad_en_meses,
		z.AfiliadosEmpresa  TotalAfiliados,
		isnull(cr.Capital_adeudado,0) Capital_adeudado,
		Case 
			when y.EmpresaEsPensionado=0 and (y.EmpresaNombre like '%corpo%' or y.EmpresaNombre like '%corp%') then 'Publicos'
            when y.EmpresaEsPensionado=0 and (y.EmpresaNombre like '%municip%' or y.EmpresaNombre like '%mun.%' 
                or y.EmpresaNombre like '%munic.%' 
                or y.EmpresaNombre like '%munin.%') then 'Publicos'
            when y.EmpresaEsPensionado=0 and y.Empresa_Rut in(65321890,61930600,60902063,65473570,65199980) then 'Publicos'
			When y.EmpresaEsPublico=1 Then 'Publicos'
			When y.EmpresaEsPrivado=1 Then 'Privados'
			when y.EmpresaEsPensionado=1 then 'Pensionados'
         End Segmento,
		 y.Telefono1,
		 y.Telefono2,
		 y.Celular,
		 y.Email

	from BD_ODS..TabCred_credito_InterCaja x
	inner join BD_ODS..TabAfi_AfiliadoTablon y ON x.RUT_EMPRESA = y.Empresa_Rut AND x.DEUDOR_RUT = y.Afiliado_Rut
	inner join (select Empresa_Rut, count(*) AfiliadosEmpresa
				from BD_ODS..TabAfi_AfiliadoTablon
				group by Empresa_Rut) z ON z.Empresa_Rut = y.Empresa_Rut
	left join BD_CAMPANIAS..TabCmp_Maestra_Creditos cr ON y.Afiliado_Rut = cr.Rut_Afiliado
	WHERE x.PERIODO = (@Periodo-2)
	group by y.Afiliado_Rut, 
		y.Afiliado_Dv, 
		y.Nombre,
		y.Apellido,
		y.Empresa_Rut, 
		y.Empresa_Dv, 
		y.EmpresaNombre, 
		y.MontoRenta,
		y.MontoPension,
		y.AntiguedadCajaAfiMeses,
		z.AfiliadosEmpresa,
		isnull(cr.Capital_adeudado,0),
		Case 
			when y.EmpresaEsPensionado=0 and (y.EmpresaNombre like '%corpo%' or y.EmpresaNombre like '%corp%') then 'Publicos'
            when y.EmpresaEsPensionado=0 and (y.EmpresaNombre like '%municip%' or y.EmpresaNombre like '%mun.%' 
                or y.EmpresaNombre like '%munic.%' 
                or y.EmpresaNombre like '%munin.%') then 'Publicos'
            when y.EmpresaEsPensionado=0 and y.Empresa_Rut in(65321890,61930600,60902063,65473570,65199980) then 'Publicos'
			When y.EmpresaEsPublico=1 Then 'Publicos'
			When y.EmpresaEsPrivado=1 Then 'Privados'
			when y.EmpresaEsPensionado=1 then 'Pensionados'
         End,
		 y.Telefono1,
		 y.Telefono2,
		 y.Celular,
		 y.Email





		SET @SQL_STMT = 'select Empresa_Rut, Count(*) cntAfil
				into #AfiliadosEmpresa
				From bd_ods..TabAfi_AfiliadoTablon
				group by Empresa_Rut

				SELECT	Afiliado_Rut 
				,Afiliado_Dv
				,MontoRenta
				,MontoPension
				,Segmento
				,a.Empresa_Rut
				,Empresa_Dv		
				,Antiguedad_en_Meses
				,b.cntAfil total_de_afiliados
				,c.Capital_adeudado
		
				into BD_PUBLICACION.dbo.Universo_Afiliados_' + CONVERT(VARCHAR(6), @Periodo) + '
				FROM TabCmp_UniversoAfiliados a
				inner join #AfiliadosEmpresa b on a.Empresa_Rut = b.Empresa_Rut
				left join BD_CAMPANIAS.dbo.TabCmp_Maestra_Creditos c on a.Afiliado_Rut = c.Rut_Afiliado
				where Periodo = '+ CONVERT(VARCHAR(6), @Periodo) + '
				
				SELECT	
				a.Afiliado_Rut 
				,a.Afiliado_Dv
				,a.MontoRenta
				,a.MontoPension
				,a.Segmento
				,a.Empresa_Rut
				,a.Empresa_Dv		
				,a.Antiguedad_en_Meses
				,a.TotalAfiliados
				,a.CantidadCreditos
				,a.Monto_Intercaja
				,a.Capital_adeudado
		
				into BD_PUBLICACION.dbo.Universo_Afiliados_Intercaja_' + CONVERT(VARCHAR(6), @Periodo) + '
				FROM BD_CAMPANIAS.dbo.TabCmp_UniversoAfiliados_Intercaja a
				where Periodo = '+ CONVERT(VARCHAR(6), @Periodo)
				
				
				

		EXEC (@SQL_STMT);

    
END
