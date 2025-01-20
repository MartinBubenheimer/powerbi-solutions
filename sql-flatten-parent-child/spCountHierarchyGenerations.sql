SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Martin Bubenheimer, Hubster.s GmbH
-- Create Date: 2022-10-20
-- Description: Counts max. number of generations in a parent-child hierarchy
-- =============================================
CREATE PROCEDURE dbo.spCountHierarchyGenerations
(
    @TableName nchar(255),
    @IdColumn nchar(255),
	@ParentIdColumn nchar(255)
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

	DECLARE @Generations int
	DECLARE @SQL NVARCHAR(4000)

	SET @SQL = '
		WITH Hierarchy(ChildId, Generation, ParentId)
		AS
		(
			SELECT ' + @IdColumn + ', 0, ' + @ParentIdColumn + '
				FROM ' + @TableName + ' AS FirtGeneration
				WHERE ' + @ParentIdColumn + ' IS NULL        
			UNION ALL
			SELECT NextGeneration.' + @IdColumn + ', Parent.Generation + 1, Parent.ChildId
				FROM ' + @TableName + ' AS NextGeneration
				INNER JOIN Hierarchy AS Parent ON NextGeneration.' + @ParentIdColumn + ' = Parent.ChildId    
		)
		SELECT *
			FROM Hierarchy
			OPTION(MAXRECURSION 32767)
	'

	DECLARE @HierarchyTable TABLE (
		ChildId nchar(255),
		Generation int,
		ParentId nchar(255)
	)

	INSERT INTO @HierarchyTable(ChildId, Generation, ParentId)
	EXEC(@SQL)

	RETURN (SELECT Generations = MAX(Generation) FROM @HierarchyTable) + 1
END
GO
