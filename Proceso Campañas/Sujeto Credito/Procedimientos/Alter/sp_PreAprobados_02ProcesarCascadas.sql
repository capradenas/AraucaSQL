USE [BD_CAMPANIAS]
GO
/****** Object:  StoredProcedure [dbo].[sp_PreAprobados_02ProcesarCascadas]    Script Date: 21/11/2016 12:57:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Carlos Pradenas
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[sp_PreAprobados_02ProcesarCascadas]
@Periodo int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	exec sp_PreAprobados_MotorCascadas @Periodo, 'Pensionados'

	exec sp_PreAprobados_MotorCascadas @Periodo, 'Trabajadores'
	
	insert into TabCmp_SujetoCredito
	select 
	 Periodo
	,Afiliado_Rut
	,Afiliado_Dv
	,Nombre
	,Apellido
	,Empresa_Rut
	,Empresa_Dv
	,Empresa
	,ClaRiesgoEmpresa
	,Holding
	,Celular
	,Telefono1
	,Telefono2
	,Email
	,MontoPension
	,MontoRenta
	,Monto_preaprobado
	,Antiguedad_en_Meses
	,LicMedicaVigente
	,CreditosVigentes
	,CredVig_Meses_Morosos
	,CredVig_MontoCuota
	,EsPensionado
	,EsPrivado
	,EsPublico
	,Contacto
	,Segmento
	,FechaNacimiento
	,Edad
	,PensionadoFFAA
	,EmpresaEsPensionado
	,EmpresaEsPublico
	,EmpresaEsPrivado
	,RiesgoPerfil
	,RiesgoMaxVecesRenta
	,RiesgoMaxPreAprobado
	,PreAprobadoFinal
	
	from (
		select *,
			ROW_NUMBER() over(partition by Afiliado_Rut Order By PreAprobadoFinal asc) rnk 		
	
		from TabCmp_UniversoAfiliados A
		WHERE Periodo = @Periodo
		AND Filtro IS NULL
		
	) T
	WHERE rnk = 1

END
