USE Xcenda_DW
GO
/***** INSERTING INTO SECTION ACCESS APPS *******/

--SELECT DISTINCT APPNAME FROM SECTION_ACCESS_APP

--INSERT INTO [Xcenda_DW].[dbo].[SECTION_ACCESS_APP]
SELECT 
	'PROJECTHEALTH' AS APPNAME,
	'ADMIN' AS ACCESS,
	'ABC\' + UPPER(E.[Employee Login]) AS USERID,
	'*' AS ACESS_CODE,
	'False' AS EXECUTIVE_STAFF,
	E.[Employee Name]
	--[Employee Termination Date]
	--,*
FROM [Xcenda_DW].[dbo].[DimEmployee] E
WHERE [Employee Termination Date] is null
AND [Employee Login] <> ''
AND E.[Employee Name] like '%julian%'
GROUP BY [Employee Name], 'ABC\' + UPPER(E.[Employee Login]), [Employee Termination Date]
ORDER BY E.[Employee Termination Date] Desc



/***** INSERTING INTO SECTION ACCESS PROJECT APPEND *******/


--INSERT INTO [Xcenda_DW].[dbo].[SECTION_ACCESS_PROJECT_APPEND]
SELECT 
	--'PROJECTHEALTH' AS APPNAME,
	'ADMIN' AS ACCESS,
	'ABC\' + UPPER(E.[Employee Login]) AS USERID,
	--'RPI' AS PHASE_SERVICELINE_CODE,
	'*' AS ACESS_CODE,
	--'False' AS EXECUTIVE_STAFF,
	E.[Employee Name]
	--[Employee Termination Date]
	--,*
FROM [Xcenda_DW].[dbo].[DimEmployee] E
WHERE [Employee Termination Date] is null
AND [Employee Login] <> ''
AND E.[Employee Name] like '%julian%'
GROUP BY [Employee Name], 'ABC\' + UPPER(E.[Employee Login]), [Employee Termination Date]
ORDER BY E.[Employee Termination Date] Desc