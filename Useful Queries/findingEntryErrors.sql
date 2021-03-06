/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [Employee Name]
      ,[Employee Login]
      ,[Employee Email]
  FROM [Xcenda_DW].[dbo].[DimEmployee]
  where len([Employee Name]) < 20
  and [Current] = 1
  and [Employee Email] <> ' '
  and rtrim([Employee Name]) not like '% %'
  order by len([Employee Name]) asc

SELECT [Name]
      ,[Title]
  FROM [Xcenda_DW].[Staging].[Employee]
  where name like '%Catherine%'