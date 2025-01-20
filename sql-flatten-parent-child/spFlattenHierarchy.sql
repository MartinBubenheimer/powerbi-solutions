-- To do:
-- * Escape single quotes and square brackets in strings that go into SQL code where necessary (also inside of loops).
-- * In unbalanced recursive hierarchies, user might want to see each node also as a child of their own in order to see the value assigned to the node isolated.
--   To achieve this, the levels below the row depth should be filled with the last value instead of null.
--   Possible solution: SQL-pattern [Level 3] = COALESCE(<Calculation for Level 3 name>, [Level 2], [Level 1]) etc., code needs to be generated.
--   To test wether this will also require adoptions in the measures/calculation groups.
-- * Take SCD Type 2 versioned hierarchy tables into account. Might not even need a change in this script. To be tested.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Martin Bubenheimer, Hubster.s GmbH
-- Create Date: 2022-10-20
-- Description: Retruns a table with parent-child hierachy as table with one column per generation
-- =============================================
CREATE PROCEDURE [dbo].[spFlattenHierarchy]
(
     @TableName nvarchar(MAX)                       -- Can be the name of a table or view, with or without schema, with or without square brackets. Input table may not have a column named [Path].
    ,@IdColumn nvarchar(MAX)
	,@ParentIdColumn nvarchar(MAX)
	,@NameColumn nvarchar(MAX)
	,@MinGenerations int = 1                        -- Minimum number of generation columns that shall be created
	,@PathDelimiter nchar = N'|'                    -- Choose a character that does not exist in the ID and Name columns.
	,@GenerationLabel nvarchar(MAX) = N'Generation' -- Text used to name the generation columns
	,@StartGenerationNumber int = 0                 -- The number used for the topmost generation
	,@Assignment nvarchar(10) = N'standard'          -- 'standard': only the next generation is on the level below a node, 'recursive': each node is repeated in the next generation
--	,@IdLabel nvarchar(MAX) = N'ID'                 -- Suffix used for generation ID columns, e.g. 'ID', 'No.', etc.
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

	DECLARE @GenerationCount int
	EXEC @GenerationCount = [dbo].[spCountHierarchyGenerations]
		@TableName = @TableName,
		@IdColumn = @IdColumn,
		@ParentIdColumn = @ParentIdColumn

	IF @GenerationCount + 1 < @MinGenerations
		SET @GenerationCount = @MinGenerations
	ELSE
		SET @GenerationCount = @GenerationCount + 1

	--DECLARE @IdColumns nvarchar(MAX)
	--SET @IdColumns = ''
	DECLARE @NameColumns nvarchar(MAX)
	SET @NameColumns = ''
	DECLARE @Generation int
	DECLARE @XmlIndex int
	
	--SET @Generation = @StartGenerationNumber
	--WHILE @Generation < @GenerationCount + @StartGenerationNumber
	--BEGIN
	--	SET @XmlIndex = 1 + @Generation - @StartGenerationNumber
	--	IF @Generation <> @StartGenerationNumber
	--		SET @IdColumns = @IdColumns + ','
	--	SET @IdColumns = @IdColumns + '
	--		[' + @GenerationLabel + ' ' + CAST(@Generation AS nvarchar(MAX)) + ' ' + @IdLabel + '] = XmlPath.value(''/x[' + CAST(@XmlIndex AS nvarchar(MAX)) + ']'',''nvarchar(max)'')
	--	'
	--	SET @Generation = @Generation + 1
	--END
	IF (@Assignment = 'standard' OR @Assignment = '0')
		BEGIN
			SET @Generation = @StartGenerationNumber
			WHILE @Generation < @GenerationCount + @StartGenerationNumber
			BEGIN
				SET @XmlIndex = 1 + @Generation - @StartGenerationNumber
				IF @Generation <> @StartGenerationNumber
					SET @NameColumns = @NameColumns + ','
				SET @NameColumns = @NameColumns + '
					[' + @GenerationLabel + ' ' + CAST(@Generation AS nvarchar(MAX)) + '] = XmlPath.value(''/x[' + CAST(@XmlIndex AS nvarchar(MAX)) + ']'',''nvarchar(max)'')
				'
				SET @Generation = @Generation + 1
			END
		END
	ELSE
		BEGIN
			SET @Generation = @StartGenerationNumber

			WHILE @Generation < @GenerationCount + @StartGenerationNumber
			BEGIN
				SET @XmlIndex = 1 + @Generation - @StartGenerationNumber
				IF @Generation <> @StartGenerationNumber
					BEGIN
						SET @NameColumns = @NameColumns + ','
						SET @NameColumns = @NameColumns + '
							[' + @GenerationLabel + ' ' + CAST(@Generation AS nvarchar(MAX)) + '] = 
								CASE
									WHEN XmlPath.value(''/x[' + CAST(@XmlIndex AS nvarchar(MAX)) + ']'',''nvarchar(max)'') IS NULL AND
										(SELECT COUNT(Child) FROM ParentChildHierarchy WHERE Parent = A.Child) > 0
									THEN XmlPath.value(''/x[' + CAST((@XmlIndex - 1) AS nvarchar(MAX)) + ']'',''nvarchar(max)'')
									ELSE XmlPath.value(''/x[' + CAST(@XmlIndex AS nvarchar(MAX)) + ']'',''nvarchar(max)'')
								END
						'
					END
				ELSE
					BEGIN
						SET @NameColumns = @NameColumns + '
							[' + @GenerationLabel + ' ' + CAST(@Generation AS nvarchar(MAX)) + '] = XmlPath.value(''/x[' + CAST(@XmlIndex AS nvarchar(MAX)) + ']'',''nvarchar(max)'')
						'
					END
				SET @Generation = @Generation + 1
			END

		END

	DECLARE @Sql nvarchar(MAX)
	SET @Sql = '
		WITH ParentChildHierarchy AS (
			SELECT 
				 pc.Name
				,pc.Child
				,pc.Parent
				,Path = CAST(pc.Child AS nvarchar(MAX))
				,NamePath = CAST(CAST((SELECT pc.Name FOR XML PATH('''')) AS XML) AS nvarchar(MAX))
				,[Path Length]
			FROM (
				SELECT
					 Name = ' + @NameColumn + '
					,Child = ' + @IdColumn + '
					,Parent = ' + @ParentIdColumn + '
					,[Path Length] = 1
				FROM
					' + @TableName + '
			) pc
			WHERE  pc.Parent IS NULL
			UNION ALL
			SELECT
				 Name = r.Name
				,Child = r.Child
				,Parent = r.Parent 
				,Path = CAST(p.Path + ''' + @PathDelimiter + ''' + CAST(r.Child AS nvarchar(MAX)) AS nvarchar(MAX))
				,NamePath = CAST(p.NamePath + N''' + @PathDelimiter + ''' + CAST(CAST((SELECT r.Name FOR XML PATH('''')) AS XML) AS nvarchar(MAX)) AS nvarchar(MAX))
				,[Path Length] = [Path Length] + 1
			FROM (
				SELECT
					 Name = ' + @NameColumn + '
					,Child = ' + @IdColumn + '
					,Parent = ' + @ParentIdColumn + '
				FROM
					' + @TableName + '
			) r
			JOIN ParentChildHierarchy p on r.Parent  = p.Child
		)
		SELECT
			 [Path Id] = Child
			,Path
			,[Path Length]
			,Children = (SELECT COUNT(Child) FROM ParentChildHierarchy WHERE Parent = A.Child)
			,N.* ' +
--'			,B.* ' +
'		INTO [#HierarchyColumns]
		FROM ParentChildHierarchy A ' +
--'		CROSS APPLY (
--			SELECT
--				' + @IdColumns + '
--			FROM (
--				SELECT XmlPath = CAST(''<x>'' + REPLACE(Path,''' + @PathDelimiter + ''',''</x><x>'')+''</x>'' AS xml)
--			) AS X 
--		) B ' + 
'		CROSS APPLY (
			SELECT
				' + @NameColumns + '
			FROM (
				SELECT XmlPath = CAST(''<x>'' + REPLACE(NamePath,''' + @PathDelimiter + ''',''</x><x>'')+''</x>'' AS xml)
			) AS X 
		) N

		SELECT 
			t.*,
			h.*
		INTO [#FullDimensionTable]
		FROM ' + @TableName + ' t
		LEFT JOIN [#HierarchyColumns] h ON h.[Path Id] = t.' + @IdColumn + '

		ALTER TABLE [#FullDimensionTable] DROP COLUMN [Path Id]

		SELECT * FROM [#FullDimensionTable]
	'
--	PRINT(@SQL)
	EXEC(@Sql)
END
GO