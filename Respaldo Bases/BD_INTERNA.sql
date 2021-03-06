USE [BD_INTERNA]
GO
/****** Object:  User [usr_reporteria]    Script Date: 20/01/2017 10:24:29 ******/
CREATE USER [usr_reporteria] FOR LOGIN [usr_reporteria] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [usr_reporteria]
GO
/****** Object:  StoredProcedure [dbo].[sp_GenerarExcel]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_GenerarExcel]
(
    @db_name    varchar(100),
    @table_name varchar(100),   
    @file_name  varchar(100)
)
as

--Generate column names as a recordset
declare @columns varchar(8000), @sql varchar(8000), @data_file varchar(100)
select 
    @columns=coalesce(@columns+',','')+column_name+' as '+column_name 
from 
    information_schema.columns
where 
    table_name=@table_name
select @columns=''''''+replace(replace(@columns,' as ',''''' as '),',',',''''')

--Create a dummy file to have actual data
select @data_file=substring(@file_name,1,len(@file_name)-charindex('\',reverse(@file_name)))+'\data_file.xls'

--Generate column names in the passed EXCEL file
set @sql='exec master..xp_cmdshell ''bcp " select * from (select '+@columns+') as t" queryout "'+@file_name+'" -c'''
exec(@sql)

--Generate data in the dummy file
set @sql='exec master..xp_cmdshell ''bcp "select * from '+@db_name+'..'+@table_name+'" queryout "'+@data_file+'" -c'''
exec(@sql)

--Copy dummy file to passed EXCEL file
set @sql= 'exec master..xp_cmdshell ''type '+@data_file+' >> "'+@file_name+'"'''
exec(@sql)

--Delete dummy file 
set @sql= 'exec master..xp_cmdshell ''del '+@data_file+''''
exec(@sql)
GO
/****** Object:  StoredProcedure [dbo].[sp_SCA_ActualizaDatosToken]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SCA_ActualizaDatosToken]
	@TokenId INT,
	@UserId VARCHAR(20),
  @AuthToken VARCHAR(200),
	@IssuedOn DATETIME,
	@ExpiresOn DATETIME

AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
	UPDATE [BD_INTERNA].[dbo].[SCA_Tokens] 
	SET [UserId] = @UserId, 
			[AuthToken] = @AuthToken, 
			[IssuedOn] = @IssuedOn, 
			[ExpiresOn] = @ExpiresOn
	WHERE TokenId = @TokenId
		
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SCA_AsociaGruposUsuario]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_SCA_AsociaGruposUsuario]
	@IdUsuario varchar(50),
	@IdGrupo int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO SCA_GruposDeUsuario
    VALUES(@IdUsuario, @IdGrupo);
    
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SCA_DatosToken]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SCA_DatosToken]
	@AuthToken VARCHAR(300)
AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
	SELECT * 
	FROM SCA_Tokens
	WHERE AuthToken = @AuthToken;

END
GO
/****** Object:  StoredProcedure [dbo].[sp_SCA_EliminaToken]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SCA_EliminaToken]
	@AuthToken VARCHAR(200)

AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
	DELETE FROM [BD_INTERNA].[dbo].[SCA_Tokens] 
	WHERE AuthToken = @AuthToken
		
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SCA_EliminaTokenByUsuario]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SCA_EliminaTokenByUsuario]
	@UserID VARCHAR(20)

AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
	DELETE FROM [BD_INTERNA].[dbo].[SCA_Tokens] 
	WHERE UserId = @UserID
		
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SCA_InsertDatosToken]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SCA_InsertDatosToken]
	@UserId VARCHAR(20),
  @AuthToken VARCHAR(200),
	@IssuedOn DATETIME,
	@ExpiresOn DATETIME

	
AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
	INSERT INTO [BD_INTERNA].[dbo].[SCA_Tokens] ([UserId], [AuthToken], [IssuedOn], [ExpiresOn]) 
	VALUES (@UserId, @AuthToken, @IssuedOn, @ExpiresOn)
		
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SCA_InsetaUsuario]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SCA_InsetaUsuario]
  @IdUsuario AS varchar(20) ,
  @Nombres AS varchar(300) ,
  @ClaveAcceso AS varchar(50) ,
  @Estado AS varchar(20) 
AS
BEGIN
  
INSERT INTO SCA_Usuario VALUES(
@IdUsuario,
@Nombres,
@ClaveAcceso,
@Estado
)


END
GO
/****** Object:  StoredProcedure [dbo].[sp_SCA_ListarGrupos]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_SCA_ListarGrupos]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT *
	FROM SCA_Grupo 
END


GO
/****** Object:  StoredProcedure [dbo].[sp_SCA_ListarRecursos]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_SCA_ListarRecursos]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select rec_id,
				 rec_id_padre,
				 rec_nombre,
				 rec_tipo,
				 rec_url,
				 rec_icono
	from SCA_Recurso
	ORDER BY rec_orden

END

GO
/****** Object:  StoredProcedure [dbo].[sp_SCA_ListarRecursosDeUsuario]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_SCA_ListarRecursosDeUsuario]
	@AuthToken varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    WITH CTE_Recurso  (rec_id, rec_id_padre, rec_tipo, rec_nombre, rec_icono, rec_url, rec_orden, rec_level)
	 AS 
	(

		select d.rec_id, d.rec_id_padre, d.rec_tipo, d.rec_nombre, d.rec_icono, d.rec_url, d.rec_orden, 0 rec_level 
		from SCA_Usuario a
		inner join SCA_GruposDeUsuario b ON a.usr_id = b.gus_id_usuario
		inner join SCA_UsoRecurso c ON b.gus_id_grupo = c.ure_id_grupo
		inner join SCA_Recurso d ON c.ure_id_recurso = d.rec_id
		INNER JOIN SCA_Tokens tk ON tk.UserId = a.usr_id
		where tk.AuthToken = @AuthToken
		--and d.rec_tipo <> 'INT'

		union ALL

		select x.rec_id, x.rec_id_padre, x.rec_tipo, x.rec_nombre, x.rec_icono, x.rec_url, x.rec_orden, rec_level + 1
		from SCA_Recurso x
		inner join CTE_Recurso rc on rc.rec_id_padre = x.rec_id		
	
	)


	SELECT distinct * 
	FROM CTE_Recurso
	order by rec_orden


END

GO
/****** Object:  StoredProcedure [dbo].[sp_SCA_ListarUsuarios]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_SCA_ListarUsuarios]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT * 
	FROM SCA_Usuario

END

GO
/****** Object:  StoredProcedure [dbo].[sp_SCA_ObtenerGruposUsuario]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_SCA_ObtenerGruposUsuario]
	@IdUsuario VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT y.grp_id, y.grp_nombre
	FROM SCA_GruposDeUsuario x 
	INNER JOIN SCA_Grupo y ON x.gus_id_grupo = y.grp_id
	WHERE x.gus_id_usuario = @IdUsuario
END


GO
/****** Object:  StoredProcedure [dbo].[sp_SCA_ObtenerUsuario]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_SCA_ObtenerUsuario]
	@IdUsuario VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET LANGUAGE spanish;

	SELECT * 
	FROM SCA_Usuario
	WHERE usr_id = @IdUsuario

END

GO
/****** Object:  StoredProcedure [dbo].[spLOG_EjecutarValidacion]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spLOG_EjecutarValidacion]
	
	@Validacion_key VARCHAR(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	DECLARE @Consulta_Valida NVARCHAR(500)
	DECLARE @Consulta_final NVARCHAR(500)
	
	DECLARE @ValiCodigo NVARCHAR(50)
	DECLARE @ValiDesc NVARCHAR(500)
	DECLARE @ValiRegla NVARCHAR(500)
	DECLARE @ResultCountConsul INT;

	DECLARE cValidaciones CURSOR LOCAL FOR
		SELECT  Codigo, Descripcion,Regla
		FROM  LOG_RegistroError
		WHERE Validacion_key = @Validacion_key;
	
	SELECT @Consulta_Valida = Consulta_validatoria
	FROM BD_INTERNA..LOG_Validacion
	WHERE Validacion_key = @Validacion_key
    
	IF @Consulta_Valida is null or @Consulta_Valida = '' 
	BEGIN
		PRINT N'Codigo de validacion no valido'
	END
	ELSE 
	BEGIN
		

		OPEN cValidaciones
		FETCH cValidaciones 
		INTO @ValiCodigo, @ValiDesc, @ValiRegla

		WHILE (@@FETCH_STATUS = 0 )
		BEGIN
			SET @Consulta_final =''
			/*Si la consulta validatoria no tiene where: se agrega uno por defecto con una logica verdadera*/
			IF ( CHARINDEX('where', LOWER(@Consulta_Valida)) <= 0)
			BEGIN
				 SET @Consulta_final = @Consulta_Valida + ' WHERE 1=1';
			END
			ELSE
			BEGIN
				SET @Consulta_final = @Consulta_Valida;
			END


			SET @Consulta_final = 'select @Salida=count(*) from (' + @Consulta_final + ' and ' + @ValiRegla + ') T'
			
			PRINT @Consulta_final
			EXECUTE sp_executesql  @Consulta_final, N'@Salida INT OUTPUT', @Salida = @ResultCountConsul OUTPUT

			IF (@ResultCountConsul > 0)
			BEGIN
				INSERT INTO LOG_SeguimientoError VALUES (@Validacion_key,GETDATE(), @ValiCodigo, @ValiDesc);
			END


			FETCH cValidaciones 
			INTO  @ValiCodigo, @ValiDesc, @ValiRegla
		END
		CLOSE cValidaciones
		DEALLOCATE cValidaciones

	END

END

GO
/****** Object:  UserDefinedFunction [dbo].[Format]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Format](@num int)
returns varChar(30)
As
Begin
Declare @out varChar(30) = ''

  while @num > 0 Begin
      Set @out = str(@num % 1000, 3, 0) + Coalesce(','+@out, '')
      Set @num = @num / 1000
  End
  Return @out
End
GO
/****** Object:  UserDefinedFunction [dbo].[InitialCap]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[InitialCap](@String VARCHAR(8000))
                  RETURNS VARCHAR(8000)
                 AS
 BEGIN 

                   DECLARE @Position INT;

SELECT @String   = STUFF(LOWER(@String),1,1,UPPER(LEFT(@String,1))) COLLATE Modern_Spanish_CI_AS,
                    @Position = PATINDEX('%[^A-Za-z''][a-z]%',@String COLLATE Modern_Spanish_CI_AS);

                    WHILE @Position > 0
                    SELECT @String   = STUFF(@String,@Position,2,UPPER(SUBSTRING(@String,@Position,2))) COLLATE Modern_Spanish_CI_AS,
                    @Position = PATINDEX('%[^A-Za-z''][a-z]%',@String COLLATE Modern_Spanish_CI_AS);

                     RETURN @String;
  END ;
GO
/****** Object:  UserDefinedFunction [dbo].[ObtenerDigitoVerificador]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  FUNCTION [dbo].[ObtenerDigitoVerificador]
(
	@rut INTEGER
 )
 RETURNS VARCHAR(1)

 AS
 BEGIN

 DECLARE @dv VARCHAR(1)
 DECLARE @rutAux INTEGER
 DECLARE @Digito INTEGER
 DECLARE @Contador INTEGER
 DECLARE @Multiplo INTEGER
 DECLARE @Acumulador INTEGER


 SET @Contador = 2;
 SET @Acumulador = 0;
 SET @Multiplo = 0;

	WHILE(@rut!=0)
		BEGIN

			SET @Multiplo = (@rut % 10) * @Contador;
			SET @Acumulador = @Acumulador + @Multiplo;
			SET @rut = @rut / 10;
			SET @Contador = @Contador + 1;
			if(@Contador = 8)
			BEGIN
				SET @Contador = 2;
			End;
		END;

	SET @Digito = 11 - (@Acumulador % 11);

	SET @dv = LTRIM(RTRIM(CONVERT(VARCHAR(2),@Digito)));

	IF(@Digito = 10)
	BEGIN
		SET @dv = 'K';
	END;

	IF(@Digito = 11)
	BEGIN
		SET @dv = '0';
	END;

RETURN @dv

END


GO
/****** Object:  Table [dbo].[LOG_RegistroError]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LOG_RegistroError](
	[Validacion_key] [varchar](50) NOT NULL,
	[Codigo] [varchar](20) NOT NULL,
	[Descripcion] [varchar](500) NOT NULL,
	[Regla] [varchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LOG_SeguimientoError]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LOG_SeguimientoError](
	[Validacion_key] [varchar](50) NOT NULL,
	[FechaHora] [datetime] NOT NULL,
	[Codigo] [varchar](20) NOT NULL,
	[Descripcion] [varchar](500) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LOG_Validacion]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LOG_Validacion](
	[Validacion_key] [varchar](50) NOT NULL,
	[Nombre] [varchar](255) NOT NULL,
	[Consulta_validatoria] [varchar](500) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SCA_Grupo]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SCA_Grupo](
	[grp_id] [int] IDENTITY(1,1) NOT NULL,
	[grp_nombre] [varchar](500) NULL,
	[grp_sistema] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[grp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SCA_GruposDeUsuario]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SCA_GruposDeUsuario](
	[gus_id_usuario] [varchar](50) NULL,
	[gus_id_grupo] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SCA_Recurso]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SCA_Recurso](
	[rec_id] [int] IDENTITY(1,1) NOT NULL,
	[rec_id_padre] [int] NULL,
	[rec_tipo] [varchar](10) NULL,
	[rec_nombre] [varchar](500) NULL,
	[rec_url] [varchar](500) NULL,
	[rec_icono] [varchar](300) NULL,
	[rec_orden] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[rec_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SCA_Sistema]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SCA_Sistema](
	[sis_id] [int] IDENTITY(1,1) NOT NULL,
	[sis_nombre] [varchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[sis_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SCA_Tokens]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SCA_Tokens](
	[TokenId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [varchar](20) NULL,
	[AuthToken] [nvarchar](250) NOT NULL,
	[IssuedOn] [datetime] NOT NULL,
	[ExpiresOn] [datetime] NOT NULL,
 CONSTRAINT [PK_Tokens] PRIMARY KEY CLUSTERED 
(
	[TokenId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SCA_UsoRecurso]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SCA_UsoRecurso](
	[ure_id_recurso] [int] NOT NULL,
	[ure_id_grupo] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ure_id_recurso] ASC,
	[ure_id_grupo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SCA_Usuario]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SCA_Usuario](
	[usr_id] [varchar](50) NOT NULL,
	[usr_nombres] [varchar](500) NULL,
	[usr_clave] [varchar](500) NULL,
	[usr_estado] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[usr_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  UserDefinedFunction [dbo].[CUST_SplitString]    Script Date: 20/01/2017 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CUST_SplitString]
(
    @String NVARCHAR(4000),
    @Delimiter NCHAR(1)
)
RETURNS TABLE 
AS
RETURN 
(
    WITH Split(stpos,endpos) 
    AS(
        SELECT 0 AS stpos, CHARINDEX(@Delimiter,@String) AS endpos
        UNION ALL
        SELECT endpos+1, CHARINDEX(@Delimiter,@String,endpos+1) 
        FROM Split
        WHERE endpos > 0
    )
    SELECT 'Id' = ROW_NUMBER() OVER (ORDER BY (SELECT 1)),
        'Data' = SUBSTRING(@String,stpos,COALESCE(NULLIF(endpos,0),LEN(@String)+1)-stpos)
    FROM Split
)
GO
