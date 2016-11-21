USE [BD_CAMPANIAS]
GO
/****** Object:  StoredProcedure [dbo].[sp_PreAprobados_MotorCascadas]    Script Date: 21/11/2016 11:41:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[sp_PreAprobados_MotorCascadas]
	@Periodo int, 
	@Segmento Varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Nombre_Filtro NVARCHAR(500), @Fuente_Filtro NVARCHAR(500), @Orden_Filtro INT, @SQL NVARCHAR(max), @Filtros_Acumulados NVARCHAR(MAX) = N'', @Perstring NVARCHAR(6), @CantPasan int, @CantCaen int

	DECLARE ValCascada_Cursor CURSOR FOR   
	SELECT Nombre_Filtro, Fuente_Filtro, Orden 
	FROM TabCmp_Cascadas_Filtro
	WHERE Segmento = @Segmento
	ORDER BY Orden asc;



	Create table #Segtos (Segment varchar(50))
	IF (@Segmento <> 'Pensionados')
	BEGIN
		insert into #Segtos values ('Privados'), ('Publicos');
	END
	ELSE
	BEGIN
		insert into #Segtos values ('Pensionados');
	END

	delete from TabCmp_ResumenCascada
	where Periodo = @Periodo
	and Segmento = @Segmento
	
	
	update TabCmp_UniversoAfiliados
	set Filtro = null
	where Segmento IN (SELECT Segment FROM #Segtos)
	AND Periodo = @Periodo


	TRUNCATE TABLE BD_CAMPANIAS.dbo.TabCmp_UniversoAfiliadosCascadas

	INSERT INTO BD_CAMPANIAS.dbo.TabCmp_UniversoAfiliadosCascadas
	SELECT *  
	--INTO BD_CAMPANIAS.dbo.TabCmp_UniversoAfiliadosCascadas
	FROM BD_CAMPANIAS.dbo.TabCmp_UniversoAfiliados a
	LEFT JOIN TabCmp_Maestra_Creditos b on a.afiliado_rut=b.Rut_Afiliado 
	WHERE Periodo = @Periodo
	AND Segmento IN (SELECT Segment FROM #Segtos)
	

	UPDATE BD_CAMPANIAS.dbo.TabCmp_UniversoAfiliadosCascadas
	SET ind_castigo = 1
	WHERE afiliado_rut in (select distinct Rut_Afiliado from TabCmp_MaestraCreditosMorosos)

	OPEN ValCascada_Cursor
	FETCH NEXT FROM ValCascada_Cursor
	INTO @Nombre_Filtro, @Fuente_Filtro, @Orden_Filtro

	WHILE @@FETCH_STATUS = 0  
	BEGIN
		
		TRUNCATE TABLE BD_CAMPANIAS.dbo.TabCmp_TemporalMotorCascadas
		SET @SQL = N'INSERT INTO BD_CAMPANIAS.dbo.TabCmp_TemporalMotorCascadas
					SELECT *  
					FROM BD_CAMPANIAS.dbo.TabCmp_UniversoAfiliadosCascadas 
					WHERE ' + @Fuente_Filtro

		EXEC(@SQL)


		SELECT @CantCaen = COUNT(1) 
		FROM TabCmp_UniversoAfiliados
		WHERE  Convert(VARCHAR(10),Afiliado_Rut) + CONVERT(VARCHAR(10), Empresa_Rut) NOT IN (SELECT  Convert(VARCHAR(10),Afiliado_Rut) + CONVERT(VARCHAR(10), Empresa_Rut) FROM TabCmp_TemporalMotorCascadas)
		AND Segmento IN (SELECT Segment FROM #Segtos)
		AND Periodo = @Periodo
		And Filtro IS NULL


		SELECT @CantPasan = COUNT(1) 
		FROM TabCmp_TemporalMotorCascadas

		UPDATE TabCmp_UniversoAfiliados 
		SET Filtro = CONVERT(NVARCHAR(2),@Orden_Filtro) + '.- ' + @Nombre_Filtro
		WHERE  Convert(VARCHAR(10),Afiliado_Rut) + CONVERT(VARCHAR(10), Empresa_Rut) NOT IN (SELECT  Convert(VARCHAR(10),Afiliado_Rut) + CONVERT(VARCHAR(10), Empresa_Rut) FROM TabCmp_TemporalMotorCascadas)
		AND Segmento IN (SELECT Segment FROM #Segtos)
		AND Periodo = @Periodo
		AND Filtro IS NULL

		
		INSERT INTO TabCmp_ResumenCascada
		VALUES(
			@Periodo,
			@Segmento,
			@CantPasan,
			CONVERT(NVARCHAR(2),@Orden_Filtro) + '.- ' + @Nombre_Filtro,
			@CantCaen
		)


		DELETE FROM BD_CAMPANIAS.dbo.TabCmp_UniversoAfiliadosCascadas
		WHERE Convert(VARCHAR(10),Afiliado_Rut) + CONVERT(VARCHAR(10), Empresa_Rut) not in (select Convert(VARCHAR(10),Afiliado_Rut) + CONVERT(VARCHAR(10), Empresa_Rut) from BD_CAMPANIAS..TabCmp_TemporalMotorCascadas)

		FETCH NEXT FROM ValCascada_Cursor
		INTO @Nombre_Filtro, @Fuente_Filtro, @Orden_Filtro

	END 
	CLOSE ValCascada_Cursor;  
	DEALLOCATE ValCascada_Cursor; 

	PRINT N'Proceso Terminado'

END
