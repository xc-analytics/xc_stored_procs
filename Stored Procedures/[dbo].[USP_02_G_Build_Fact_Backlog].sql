USE [Xcenda_DW]
GO
/****** Object:  StoredProcedure [dbo].[USP_02_G_Build_Fact_Backlog]    Script Date: 8/14/2019 11:57:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[USP_02_G_Build_Fact_Backlog]
AS
BEGIN

DECLARE @MonthEndOffSet INTEGER
SET @MonthEndOffSet=0 --CHANGE THIS TO ZERO FOR NON-MONTHEND PERIOD, SET TO 1 DURING MONTHEND P
/*
UPDATE Staging.RADAR_Backlog_report
SET Month_year = '201711'
WHERE Month_year = '201710'
*/
/*
INSERT Staging.RADAR_Backlog_report
SELECT Proj_code ,
       '201711' Month_year ,
       Proj_name ,
       ResponsibleCompanyCode ,
       ResponsibleCompanyName ,
       ResponsibleOrganizationCode ,
       ResponsibleOrganizationName ,
       Proj_type ,
       Prac_area ,
       Acct_team ,
       Prod_team ,
       Fee_contract ,
       Rem_budget ,
       Req_fee_adj ,
       Tot_fee_adj ,
       Cur_mo_pred ,
       Cur_mo_act ,
       Next_mo_1 ,
       Next_mo_2 ,
       Block_mo_3 ,
       Block_mo_4 ,
       Block_mo_5 ,
       Block_mo_6 ,
       Block_mo_7 ,
       Block_mo_8 ,
       Block_mo_9 ,
       Block_mo_10 ,
       Block_mo_11 ,
       PM_emp_id ,
       CM_emp_id ,
       PC_emp_id ,
       Signature ,
       Last_change_date ,
       Contracted ,
       PO ,
       Client_name ,
       Contracted_fees ,
       PeriodEndDate 
FROM Staging.RADAR_Backlog_report
WHERE Month_year = '201710'
*/

UPDATE dbo.DimEmployee
SET [Employee Login] = 'NA'
WHERE [Current] = 1
  AND [Employee Code] = '******'

TRUNCATE TABLE dbo.FactBacklog;

/* Current Month*/
INSERT dbo.FactBacklog
        ( Proj_code ,
		  [Backlog Project Name],
		  [Backlog Project Fee Budget],
		  [Backlog Company Name],
		  [Backlog Business Unit],
		  [Backlog ServiceLine],
		  [Backlog Project Worktype],
		  [Backlog Project Manager],
		  [Backlog Project Client Manager],
          [Backlog Year] ,
          [Backlog Month] ,
          [Backlog MonthYear] ,
          [Backlog Fiscal Year] ,
          [Backlog Fiscal Quarter] ,
		  [Backlog FirstDayOfMonthAndYear Date],
          ProjectPhaseKey ,
          EmployeeKey ,
          WorktypeKey ,
		  --PhaseServiceLineKey,
          DateKey ,
          [Backlog Client Code] ,
          [Backlog Modified By] ,
          [Backlog Modified Date] ,
          [Project Phase Code] ,
          [Project Phase Name] ,
          [Backlog Account Team] ,
          [Backlog Fee Contract] ,
          [Backlog Remaining Budget] ,
          [Backlog Fee Adjustment] ,
          [Backlog Total Fee Adjustment] ,
          [Backlog Current Month Activity] ,
          [Backlog Month Number] ,
          [Backlog Month Name] ,
          [Backlog Amount]
        )
SELECT B.Proj_code ,
	   P.[Project Name],
	   P.[Project Fee Budget],
	   P.[Project Company Name],
	   P.[Project BusinessUnit],
	   P.[Project ServiceLine],
	   P.[Project WorkType Display],
	   P.[Project Manager],
	   P.[Project Client Manager],
	   SUBSTRING(B.Month_Year, 1, 4) [Backlog Year] ,	   
	   SUBSTRING(B.Month_Year, 5, 2) [Backlog Month],
	   REPLACE(D.MonthYear, '-', ' ') [Backlog MonthYear],
	   CASE 
		WHEN SUBSTRING(B.Month_Year, 5, 2) >= 10 THEN SUBSTRING(Month_Year, 1, 4)+1
		ELSE SUBSTRING(B.Month_Year, 1, 4)
	   END [Backlog Fiscal Year],
	   CASE
		WHEN SUBSTRING(B.Month_Year, 5, 2) IN ('01','02','03') THEN '2'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('04','05','06') THEN '3'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('07','08','09') THEN '4'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('10','11','12') THEN '1'
	   END [Backlog Fiscal Quarter],
	   CASE 
			WHEN B.BacklogMonth < DATEPART(MONTH, GETDATE()) THEN CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR,DATEADD(YEAR, 1,GETDATE())) AS VARCHAR) AS DATE)
			ELSE CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR) AS DATE)
	   END [Backlog FirstDayOfMonthAndYear Date],
	   P.ProjectPhaseKey,
	   E.EmployeeKey,
	   NULL, --WorktypeKey Column
	   --NULL, --PhaseServiceLineKey
	   D.DateKey,
	   P.[Project Client Code] [Backlog Client Code],
	   B.[Signature] [Backlog Modified By],
       B.Last_change_date [Backlog Modified Date],
       P.[Project Phase Code],
	   P.[Project Phase Name],
       B.Acct_team [Backlog Account Team],
       B.Fee_contract [Backlog Fee Contract] ,
       B.Rem_budget [Backlog Remaining Budget],
       B.Req_fee_adj [Backlog Fee Adjustment],
       B.Tot_fee_adj [Backlog Total Fee Adjustment],
       B.Cur_mo_act [Backlog Current Month Activity],
       B.BacklogMonth [Backlog Month Number],
       B.MonthName [Backlog Month Name],
       B.Amount [Backlog Amount]
--INTO dbo.FactBacklog
FROM dbo.fRADAR_Backlog_report_vertical(0) B
JOIN dbo.DimProjectPhase P
  ON P.[Project Code] = B.Proj_code
 AND P.[Project Phase Code] = '****'
LEFT JOIN dbo.DimEmployee E
  ON E.[Employee Login] = ISNULL(B.Signature, 'NA')
 AND E.[Current]=1
LEFT JOIN dbo.DimDate D
  --ON D.Date = ISNULL(CAST(B.Last_change_date AS DATE), '1-1-1753')
  ON D.Date = CAST(SUBSTRING(B.Month_year, 5, 2) + '-01' + '-' +SUBSTRING(B.Month_year, 1, 4) AS DATE)
 ORDER BY P.[Project Code], B.[MonthName] DESC;

/* Last Month*/
INSERT dbo.FactBacklog
		( Proj_code ,
		  [Backlog Project Name],
		  [Backlog Project Fee Budget],
		  [Backlog Company Name],
		  [Backlog Business Unit],
		  [Backlog ServiceLine],
		  [Backlog Project Worktype],
		  [Backlog Project Manager],
		  [Backlog Project Client Manager],
          [Backlog Year] ,
          [Backlog Month] ,
          [Backlog MonthYear] ,
          [Backlog Fiscal Year] ,
          [Backlog Fiscal Quarter] ,
		  [Backlog FirstDayOfMonthAndYear Date],
          ProjectPhaseKey ,
          EmployeeKey ,
          WorktypeKey ,
		  --PhaseServiceLineKey,
          DateKey ,
          [Backlog Client Code] ,
          [Backlog Modified By] ,
          [Backlog Modified Date] ,
          [Project Phase Code] ,
          [Project Phase Name] ,
          [Backlog Account Team] ,
          [Backlog Fee Contract] ,
          [Backlog Remaining Budget] ,
          [Backlog Fee Adjustment] ,
          [Backlog Total Fee Adjustment] ,
          [Backlog Current Month Activity] ,
          [Backlog Month Number] ,
          [Backlog Month Name] ,
          [Backlog Amount]
        )
SELECT B.Proj_code , 
	   P.[Project Name],
	   P.[Project Fee Budget],
	   P.[Project Company Name],
	   P.[Project BusinessUnit],
	   P.[Project ServiceLine],
	   P.[Project WorkType Display],
	   P.[Project Manager],
	   P.[Project Client Manager],
	   SUBSTRING(B.Month_Year, 1, 4) [Backlog Year] ,	   SUBSTRING(B.Month_Year, 5, 2) [Backlog Month],
	   REPLACE(D.MonthYear, '-', ' ') [Backlog MonthYear],
	   CASE 
		WHEN SUBSTRING(B.Month_Year, 5, 2) >= 10 THEN SUBSTRING(Month_Year, 1, 4)+1
		ELSE SUBSTRING(B.Month_Year, 1, 4)
	   END [Backlog Fiscal Year],
	   CASE
		WHEN SUBSTRING(B.Month_Year, 5, 2) IN ('01','02','03') THEN '2'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('04','05','06') THEN '3'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('07','08','09') THEN '4'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('10','11','12') THEN '1'
	   END [Backlog Fiscal Quarter],
	   CASE 
			WHEN B.BacklogMonth < DATEPART(MONTH, GETDATE()) THEN CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR,DATEADD(YEAR, 1,GETDATE())) AS VARCHAR) AS DATE)
			ELSE CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR) AS DATE)
	   END [Backlog FirstDayOfMonthAndYear Date],
	   P.ProjectPhaseKey,
	   E.EmployeeKey,
	   NULL, --WorktypeKey Column
	   D.DateKey,
	   P.[Project Client Code] [Backlog Client Code],
	   B.[Signature] [Backlog Modified By],
       B.Last_change_date [Backlog Modified Date],
       --B.Proj_name ,
	   P.[Project Phase Code],
	   P.[Project Phase Name],
       --B.ResponsibleCompanyName ,
       --B.ResponsibleOrganizationName ,
       --B.Proj_type ,
       --B.Prac_area ,
       B.Acct_team [Backlog Account Team],
       B.Fee_contract [Backlog Fee Contract] ,
       B.Rem_budget [Backlog Remaining Budget],
       B.Req_fee_adj [Backlog Fee Adjustment],
       B.Tot_fee_adj [Backlog Total Fee Adjustment],
       B.Cur_mo_act [Backlog Current Month Activity],
       B.BacklogMonth [Backlog Month Number],
       B.MonthName [Backlog Month Name],
       B.Amount [Backlog Amount]
--INTO dbo.FactBacklog
FROM dbo.fRADAR_Backlog_report_vertical(1) B
JOIN dbo.DimProjectPhase P
  ON P.[Project Code] = B.Proj_code
 AND P.[Project Phase Code] = '****'
LEFT JOIN dbo.DimEmployee E
  ON E.[Employee Login] = ISNULL(B.Signature, 'NA')
 AND E.[Current]=1
LEFT JOIN dbo.DimDate D
  --ON D.Date = ISNULL(CAST(B.Last_change_date AS DATE), '1-1-1753')
  ON D.Date = CAST(SUBSTRING(B.Month_year, 5, 2) + '-01' + '-' +SUBSTRING(B.Month_year, 1, 4) AS DATE)
 ORDER BY P.[Project Code], B.[MonthName] DESC;

/* 2 Months Ago*/
INSERT dbo.FactBacklog
		( Proj_code ,
		  [Backlog Project Name],
		  [Backlog Project Fee Budget],
		  [Backlog Company Name],
		  [Backlog Business Unit],
		  [Backlog ServiceLine],
		  [Backlog Project Worktype],
		  [Backlog Project Manager],
		  [Backlog Project Client Manager],
          [Backlog Year] ,
          [Backlog Month] ,
          [Backlog MonthYear] ,
          [Backlog Fiscal Year] ,
          [Backlog Fiscal Quarter] ,
		  [Backlog FirstDayOfMonthAndYear Date],
          ProjectPhaseKey ,
          EmployeeKey ,
          WorktypeKey ,
		  --PhaseServiceLineKey,
          DateKey ,
          [Backlog Client Code] ,
          [Backlog Modified By] ,
          [Backlog Modified Date] ,
          [Project Phase Code] ,
          [Project Phase Name] ,
          [Backlog Account Team] ,
          [Backlog Fee Contract] ,
          [Backlog Remaining Budget] ,
          [Backlog Fee Adjustment] ,
          [Backlog Total Fee Adjustment] ,
          [Backlog Current Month Activity] ,
          [Backlog Month Number] ,
          [Backlog Month Name] ,
          [Backlog Amount]
        )
SELECT B.Proj_code ,
	   P.[Project Name],
	   P.[Project Fee Budget],
	   P.[Project Company Name],
	   P.[Project BusinessUnit],
	   P.[Project ServiceLine],
	   P.[Project WorkType Display],
	   P.[Project Manager],
	   P.[Project Client Manager], 
	   SUBSTRING(B.Month_Year, 1, 4) [Backlog Year] ,	   SUBSTRING(B.Month_Year, 5, 2) [Backlog Month],
	   REPLACE(D.MonthYear, '-', ' ') [Backlog MonthYear],
	   CASE 
		WHEN SUBSTRING(B.Month_Year, 5, 2) >= 10 THEN SUBSTRING(Month_Year, 1, 4)+1
		ELSE SUBSTRING(B.Month_Year, 1, 4)
	   END [Backlog Fiscal Year],
	   CASE
		WHEN SUBSTRING(B.Month_Year, 5, 2) IN ('01','02','03') THEN '2'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('04','05','06') THEN '3'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('07','08','09') THEN '4'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('10','11','12') THEN '1'
	   END [Backlog Fiscal Quarter],
	   CASE 
			WHEN B.BacklogMonth < DATEPART(MONTH, GETDATE()) THEN CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR,DATEADD(YEAR, 1,GETDATE())) AS VARCHAR) AS DATE)
			ELSE CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR) AS DATE)
	   END [Backlog FirstDayOfMonthAndYear Date],
	   P.ProjectPhaseKey,
	   E.EmployeeKey,
	   NULL, --WorktypeKey Column
	   D.DateKey,
	   P.[Project Client Code] [Backlog Client Code],
	   B.[Signature] [Backlog Modified By],
       B.Last_change_date [Backlog Modified Date],
       --B.Proj_name ,
	   P.[Project Phase Code],
	   P.[Project Phase Name],
       --B.ResponsibleCompanyName ,
       --B.ResponsibleOrganizationName ,
       --B.Proj_type ,
       --B.Prac_area ,
       B.Acct_team [Backlog Account Team],
       B.Fee_contract [Backlog Fee Contract] ,
       B.Rem_budget [Backlog Remaining Budget],
       B.Req_fee_adj [Backlog Fee Adjustment],
       B.Tot_fee_adj [Backlog Total Fee Adjustment],
       B.Cur_mo_act [Backlog Current Month Activity],
       B.BacklogMonth [Backlog Month Number],
       B.MonthName [Backlog Month Name],
       B.Amount [Backlog Amount]
--INTO dbo.FactBacklog
FROM dbo.fRADAR_Backlog_report_vertical(2) B
JOIN dbo.DimProjectPhase P
  ON P.[Project Code] = B.Proj_code
 AND P.[Project Phase Code] = '****'
LEFT JOIN dbo.DimEmployee E
  ON E.[Employee Login] = ISNULL(B.Signature, 'NA')
 AND E.[Current]=1
LEFT JOIN dbo.DimDate D
  --ON D.Date = ISNULL(CAST(B.Last_change_date AS DATE), '1-1-1753')
  ON D.Date = CAST(SUBSTRING(B.Month_year, 5, 2) + '-01' + '-' +SUBSTRING(B.Month_year, 1, 4) AS DATE)
 ORDER BY P.[Project Code], B.[MonthName] DESC;

/* 3 Months ago*/
INSERT dbo.FactBacklog
		( Proj_code ,
		  [Backlog Project Name],
		  [Backlog Project Fee Budget],
		  [Backlog Company Name],
		  [Backlog Business Unit],
		  [Backlog ServiceLine],
		  [Backlog Project Worktype],
		  [Backlog Project Manager],
		  [Backlog Project Client Manager],
          [Backlog Year] ,
          [Backlog Month] ,
          [Backlog MonthYear] ,
          [Backlog Fiscal Year] ,
          [Backlog Fiscal Quarter] ,
		  [Backlog FirstDayOfMonthAndYear Date],
          ProjectPhaseKey ,
          EmployeeKey ,
          WorktypeKey ,
		  --PhaseServiceLineKey,
          DateKey ,
          [Backlog Client Code] ,
          [Backlog Modified By] ,
          [Backlog Modified Date] ,
          [Project Phase Code] ,
          [Project Phase Name] ,
          [Backlog Account Team] ,
          [Backlog Fee Contract] ,
          [Backlog Remaining Budget] ,
          [Backlog Fee Adjustment] ,
          [Backlog Total Fee Adjustment] ,
          [Backlog Current Month Activity] ,
          [Backlog Month Number] ,
          [Backlog Month Name] ,
          [Backlog Amount]
        )
SELECT B.Proj_code ,
	   P.[Project Name],
	   P.[Project Fee Budget],
	   P.[Project Company Name],
	   P.[Project BusinessUnit],
	   P.[Project ServiceLine],
	   P.[Project WorkType Display],
	   P.[Project Manager],
	   P.[Project Client Manager], 
	   SUBSTRING(B.Month_Year, 1, 4) [Backlog Year] ,	   SUBSTRING(B.Month_Year, 5, 2) [Backlog Month],
	   REPLACE(D.MonthYear, '-', ' ') [Backlog MonthYear],
	   CASE 
		WHEN SUBSTRING(B.Month_Year, 5, 2) >= 10 THEN SUBSTRING(Month_Year, 1, 4)+1
		ELSE SUBSTRING(B.Month_Year, 1, 4)
	   END [Backlog Fiscal Year],
	   CASE
		WHEN SUBSTRING(B.Month_Year, 5, 2) IN ('01','02','03') THEN '2'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('04','05','06') THEN '3'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('07','08','09') THEN '4'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('10','11','12') THEN '1'
	   END [Backlog Fiscal Quarter],
	   CASE 
			WHEN B.BacklogMonth < DATEPART(MONTH, GETDATE()) THEN CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR,DATEADD(YEAR, 1,GETDATE())) AS VARCHAR) AS DATE)
			ELSE CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR) AS DATE)
	   END [Backlog FirstDayOfMonthAndYear Date],
	   P.ProjectPhaseKey,
	   E.EmployeeKey,
	   NULL, --WorktypeKey Column
	   D.DateKey,
	   P.[Project Client Code] [Backlog Client Code],
       --B.Client_name ,
	   B.[Signature] [Backlog Modified By],
       B.Last_change_date [Backlog Modified Date],
       --B.Proj_name ,
	   P.[Project Phase Code],
	   P.[Project Phase Name],
       --B.ResponsibleCompanyName ,
       --B.ResponsibleOrganizationName ,
       --B.Proj_type ,
       --B.Prac_area ,
       B.Acct_team [Backlog Account Team],
       B.Fee_contract [Backlog Fee Contract] ,
       B.Rem_budget [Backlog Remaining Budget],
       B.Req_fee_adj [Backlog Fee Adjustment],
       B.Tot_fee_adj [Backlog Total Fee Adjustment],
       B.Cur_mo_act [Backlog Current Month Activity],
       B.BacklogMonth [Backlog Month Number],
       B.MonthName [Backlog Month Name],
       B.Amount [Backlog Amount]
--INTO dbo.FactBacklog
FROM dbo.fRADAR_Backlog_report_vertical(3) B
JOIN dbo.DimProjectPhase P
  ON P.[Project Code] = B.Proj_code
 AND P.[Project Phase Code] = '****'
LEFT JOIN dbo.DimEmployee E
  ON E.[Employee Login] = ISNULL(B.Signature, 'NA')
 AND E.[Current]=1
LEFT JOIN dbo.DimDate D
  --ON D.Date = ISNULL(CAST(B.Last_change_date AS DATE), '1-1-1753')
  ON D.Date = CAST(SUBSTRING(B.Month_year, 5, 2) + '-01' + '-' +SUBSTRING(B.Month_year, 1, 4) AS DATE)
 ORDER BY P.[Project Code], B.[MonthName] DESC;

/* 4 Months ago*/
INSERT dbo.FactBacklog
( Proj_code ,
		  [Backlog Project Name],
		  [Backlog Project Fee Budget],
		  [Backlog Company Name],
		  [Backlog Business Unit],
		  [Backlog ServiceLine],
		  [Backlog Project Worktype],
		  [Backlog Project Manager],
		  [Backlog Project Client Manager],
          [Backlog Year] ,
          [Backlog Month] ,
          [Backlog MonthYear] ,
          [Backlog Fiscal Year] ,
          [Backlog Fiscal Quarter] ,
		  [Backlog FirstDayOfMonthAndYear Date],
          ProjectPhaseKey ,
          EmployeeKey ,
          WorktypeKey ,
		  --PhaseServiceLineKey,
          DateKey ,
          [Backlog Client Code] ,
          [Backlog Modified By] ,
          [Backlog Modified Date] ,
          [Project Phase Code] ,
          [Project Phase Name] ,
          [Backlog Account Team] ,
          [Backlog Fee Contract] ,
          [Backlog Remaining Budget] ,
          [Backlog Fee Adjustment] ,
          [Backlog Total Fee Adjustment] ,
          [Backlog Current Month Activity] ,
          [Backlog Month Number] ,
          [Backlog Month Name] ,
          [Backlog Amount]
        )
SELECT B.Proj_code ,
	   P.[Project Name],
	   P.[Project Fee Budget],
	   P.[Project Company Name],
	   P.[Project BusinessUnit],
	   P.[Project ServiceLine],
	   P.[Project WorkType Display],
	   P.[Project Manager],
	   P.[Project Client Manager],
	   SUBSTRING(B.Month_Year, 1, 4) [Backlog Year] ,	   SUBSTRING(B.Month_Year, 5, 2) [Backlog Month],
	   REPLACE(D.MonthYear, '-', ' ') [Backlog MonthYear],
	   CASE 
		WHEN SUBSTRING(B.Month_Year, 5, 2) >= 10 THEN SUBSTRING(Month_Year, 1, 4)+1
		ELSE SUBSTRING(B.Month_Year, 1, 4)
	   END [Backlog Fiscal Year],
	   CASE
		WHEN SUBSTRING(B.Month_Year, 5, 2) IN ('01','02','03') THEN '2'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('04','05','06') THEN '3'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('07','08','09') THEN '4'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('10','11','12') THEN '1'
	   END [Backlog Fiscal Quarter],
	   CASE 
			WHEN B.BacklogMonth < DATEPART(MONTH, GETDATE()) THEN CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR,DATEADD(YEAR, 1,GETDATE())) AS VARCHAR) AS DATE)
			ELSE CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR) AS DATE)
	   END [Backlog FirstDayOfMonthAndYear Date],
	   P.ProjectPhaseKey,
	   E.EmployeeKey,
	   NULL, --WorktypeKey Column
	   D.DateKey,
	   P.[Project Client Code] [Backlog Client Code],
       --B.Client_name ,
	   B.[Signature] [Backlog Modified By],
       B.Last_change_date [Backlog Modified Date],
       --B.Proj_name ,
	   P.[Project Phase Code],
	   P.[Project Phase Name],
       --B.ResponsibleCompanyName ,
       --B.ResponsibleOrganizationName ,
       --B.Proj_type ,
       --B.Prac_area ,
       B.Acct_team [Backlog Account Team],
       B.Fee_contract [Backlog Fee Contract] ,
       B.Rem_budget [Backlog Remaining Budget],
       B.Req_fee_adj [Backlog Fee Adjustment],
       B.Tot_fee_adj [Backlog Total Fee Adjustment],
       B.Cur_mo_act [Backlog Current Month Activity],
       B.BacklogMonth [Backlog Month Number],
       B.MonthName [Backlog Month Name],
       B.Amount [Backlog Amount]
--INTO dbo.FactBacklog
FROM dbo.fRADAR_Backlog_report_vertical(4) B
JOIN dbo.DimProjectPhase P
  ON P.[Project Code] = B.Proj_code
 AND P.[Project Phase Code] = '****'
LEFT JOIN dbo.DimEmployee E
  ON E.[Employee Login] = ISNULL(B.Signature, 'NA')
 AND E.[Current]=1
LEFT JOIN dbo.DimDate D
  --ON D.Date = ISNULL(CAST(B.Last_change_date AS DATE), '1-1-1753')
  ON D.Date = CAST(SUBSTRING(B.Month_year, 5, 2) + '-01' + '-' +SUBSTRING(B.Month_year, 1, 4) AS DATE)
 ORDER BY P.[Project Code], B.[MonthName] DESC;

/* 5 Months ago*/
INSERT dbo.FactBacklog
		( Proj_code ,
		  [Backlog Project Name],
		  [Backlog Project Fee Budget],
		  [Backlog Company Name],
		  [Backlog Business Unit],
		  [Backlog ServiceLine],
		  [Backlog Project Worktype],
		  [Backlog Project Manager],
		  [Backlog Project Client Manager],
          [Backlog Year] ,
          [Backlog Month] ,
          [Backlog MonthYear] ,
          [Backlog Fiscal Year] ,
          [Backlog Fiscal Quarter] ,
		  [Backlog FirstDayOfMonthAndYear Date],
          ProjectPhaseKey ,
          EmployeeKey ,
          WorktypeKey ,
		  --PhaseServiceLineKey,
          DateKey ,
          [Backlog Client Code] ,
          [Backlog Modified By] ,
          [Backlog Modified Date] ,
          [Project Phase Code] ,
          [Project Phase Name] ,
          [Backlog Account Team] ,
          [Backlog Fee Contract] ,
          [Backlog Remaining Budget] ,
          [Backlog Fee Adjustment] ,
          [Backlog Total Fee Adjustment] ,
          [Backlog Current Month Activity] ,
          [Backlog Month Number] ,
          [Backlog Month Name] ,
          [Backlog Amount]
        )
SELECT B.Proj_code , 
	   P.[Project Name],
	   P.[Project Fee Budget],
	   P.[Project Company Name],
	   P.[Project BusinessUnit],
	   P.[Project ServiceLine],
	   P.[Project WorkType Display],
	   P.[Project Manager],
	   P.[Project Client Manager],
	   SUBSTRING(B.Month_Year, 1, 4) [Backlog Year] ,	   SUBSTRING(B.Month_Year, 5, 2) [Backlog Month],
	   REPLACE(D.MonthYear, '-', ' ') [Backlog MonthYear],
	   CASE 
		WHEN SUBSTRING(B.Month_Year, 5, 2) >= 10 THEN SUBSTRING(Month_Year, 1, 4)+1
		ELSE SUBSTRING(B.Month_Year, 1, 4)
	   END [Backlog Fiscal Year],
	   CASE
		WHEN SUBSTRING(B.Month_Year, 5, 2) IN ('01','02','03') THEN '2'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('04','05','06') THEN '3'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('07','08','09') THEN '4'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('10','11','12') THEN '1'
	   END [Backlog Fiscal Quarter],
	   CASE 
			WHEN B.BacklogMonth < DATEPART(MONTH, GETDATE()) THEN CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR,DATEADD(YEAR, 1,GETDATE())) AS VARCHAR) AS DATE)
			ELSE CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR) AS DATE)
	   END [Backlog FirstDayOfMonthAndYear Date],
	   P.ProjectPhaseKey,
	   E.EmployeeKey,
	   NULL, --WorktypeKey Column
	   D.DateKey,
	   P.[Project Client Code] [Backlog Client Code],
       --B.Client_name ,
	   B.[Signature] [Backlog Modified By],
       B.Last_change_date [Backlog Modified Date],
       --B.Proj_name ,
	   P.[Project Phase Code],
	   P.[Project Phase Name],
       --B.ResponsibleCompanyName ,
       --B.ResponsibleOrganizationName ,
       --B.Proj_type ,
       --B.Prac_area ,
       B.Acct_team [Backlog Account Team],
       B.Fee_contract [Backlog Fee Contract] ,
       B.Rem_budget [Backlog Remaining Budget],
       B.Req_fee_adj [Backlog Fee Adjustment],
       B.Tot_fee_adj [Backlog Total Fee Adjustment],
       B.Cur_mo_act [Backlog Current Month Activity],
       B.BacklogMonth [Backlog Month Number],
       B.MonthName [Backlog Month Name],
       B.Amount [Backlog Amount]
--INTO dbo.FactBacklog
FROM dbo.fRADAR_Backlog_report_vertical(5) B
JOIN dbo.DimProjectPhase P
  ON P.[Project Code] = B.Proj_code
 AND P.[Project Phase Code] = '****'
LEFT JOIN dbo.DimEmployee E
  ON E.[Employee Login] = ISNULL(B.Signature, 'NA')
 AND E.[Current]=1
LEFT JOIN dbo.DimDate D
  --ON D.Date = ISNULL(CAST(B.Last_change_date AS DATE), '1-1-1753')
  ON D.Date = CAST(SUBSTRING(B.Month_year, 5, 2) + '-01' + '-' +SUBSTRING(B.Month_year, 1, 4) AS DATE)
 ORDER BY P.[Project Code], B.[MonthName] DESC;

/* 6 Months ago*/
INSERT dbo.FactBacklog
		( Proj_code ,
		  [Backlog Project Name],
		  [Backlog Project Fee Budget],
		  [Backlog Company Name],
		  [Backlog Business Unit],
		  [Backlog ServiceLine],
		  [Backlog Project Worktype],
		  [Backlog Project Manager],
		  [Backlog Project Client Manager],
          [Backlog Year] ,
          [Backlog Month] ,
          [Backlog MonthYear] ,
          [Backlog Fiscal Year] ,
          [Backlog Fiscal Quarter] ,
		  [Backlog FirstDayOfMonthAndYear Date],
          ProjectPhaseKey ,
          EmployeeKey ,
          WorktypeKey ,
		  --PhaseServiceLineKey,
          DateKey ,
          [Backlog Client Code] ,
          [Backlog Modified By] ,
          [Backlog Modified Date] ,
          [Project Phase Code] ,
          [Project Phase Name] ,
          [Backlog Account Team] ,
          [Backlog Fee Contract] ,
          [Backlog Remaining Budget] ,
          [Backlog Fee Adjustment] ,
          [Backlog Total Fee Adjustment] ,
          [Backlog Current Month Activity] ,
          [Backlog Month Number] ,
          [Backlog Month Name] ,
          [Backlog Amount]
        )
SELECT B.Proj_code ,
	   P.[Project Name],
	   P.[Project Fee Budget],
	   P.[Project Company Name],
	   P.[Project BusinessUnit],
	   P.[Project ServiceLine],
	   P.[Project WorkType Display],
	   P.[Project Manager],
	   P.[Project Client Manager],
	   SUBSTRING(B.Month_Year, 1, 4) [Backlog Year] ,	   SUBSTRING(B.Month_Year, 5, 2) [Backlog Month],
	   REPLACE(D.MonthYear, '-', ' ') [Backlog MonthYear],
	   CASE 
		WHEN SUBSTRING(B.Month_Year, 5, 2) >= 10 THEN SUBSTRING(Month_Year, 1, 4)+1
		ELSE SUBSTRING(B.Month_Year, 1, 4)
	   END [Backlog Fiscal Year],
	   CASE
		WHEN SUBSTRING(B.Month_Year, 5, 2) IN ('01','02','03') THEN '2'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('04','05','06') THEN '3'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('07','08','09') THEN '4'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('10','11','12') THEN '1'
	   END [Backlog Fiscal Quarter],
	   CASE 
			WHEN B.BacklogMonth < DATEPART(MONTH, GETDATE()) THEN CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR,DATEADD(YEAR, 1,GETDATE())) AS VARCHAR) AS DATE)
			ELSE CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR) AS DATE)
	   END [Backlog FirstDayOfMonthAndYear Date],
	   P.ProjectPhaseKey,
	   E.EmployeeKey,
	   NULL, --WorktypeKey Column
	   D.DateKey,
	   P.[Project Client Code] [Backlog Client Code],
       --B.Client_name ,
	   B.[Signature] [Backlog Modified By],
       B.Last_change_date [Backlog Modified Date],
       --B.Proj_name ,
	   P.[Project Phase Code],
	   P.[Project Phase Name],
       --B.ResponsibleCompanyName ,
       --B.ResponsibleOrganizationName ,
       --B.Proj_type ,
       --B.Prac_area ,
       B.Acct_team [Backlog Account Team],
       B.Fee_contract [Backlog Fee Contract] ,
       B.Rem_budget [Backlog Remaining Budget],
       B.Req_fee_adj [Backlog Fee Adjustment],
       B.Tot_fee_adj [Backlog Total Fee Adjustment],
       B.Cur_mo_act [Backlog Current Month Activity],
       B.BacklogMonth [Backlog Month Number],
       B.MonthName [Backlog Month Name],
       B.Amount [Backlog Amount]
--INTO dbo.FactBacklog
FROM dbo.fRADAR_Backlog_report_vertical(6) B
JOIN dbo.DimProjectPhase P
  ON P.[Project Code] = B.Proj_code
 AND P.[Project Phase Code] = '****'
LEFT JOIN dbo.DimEmployee E
  ON E.[Employee Login] = ISNULL(B.Signature, 'NA')
 AND E.[Current]=1
LEFT JOIN dbo.DimDate D
  --ON D.Date = ISNULL(CAST(B.Last_change_date AS DATE), '1-1-1753')
  ON D.Date = CAST(SUBSTRING(B.Month_year, 5, 2) + '-01' + '-' +SUBSTRING(B.Month_year, 1, 4) AS DATE)
 ORDER BY P.[Project Code], B.[MonthName] DESC;

/* 7 Months ago*/
INSERT dbo.FactBacklog
		( Proj_code ,
		  [Backlog Project Name],
		  [Backlog Project Fee Budget],
		  [Backlog Company Name],
		  [Backlog Business Unit],
		  [Backlog ServiceLine],
		  [Backlog Project Worktype],
		  [Backlog Project Manager],
		  [Backlog Project Client Manager],
          [Backlog Year] ,
          [Backlog Month] ,
          [Backlog MonthYear] ,
          [Backlog Fiscal Year] ,
          [Backlog Fiscal Quarter] ,
		  [Backlog FirstDayOfMonthAndYear Date],
          ProjectPhaseKey ,
          EmployeeKey ,
          WorktypeKey ,
		  --PhaseServiceLineKey,
          DateKey ,
          [Backlog Client Code] ,
          [Backlog Modified By] ,
          [Backlog Modified Date] ,
          [Project Phase Code] ,
          [Project Phase Name] ,
          [Backlog Account Team] ,
          [Backlog Fee Contract] ,
          [Backlog Remaining Budget] ,
          [Backlog Fee Adjustment] ,
          [Backlog Total Fee Adjustment] ,
          [Backlog Current Month Activity] ,
          [Backlog Month Number] ,
          [Backlog Month Name] ,
          [Backlog Amount]
        )
SELECT B.Proj_code ,
	   P.[Project Name],
	   P.[Project Fee Budget],
	   P.[Project Company Name],
	   P.[Project BusinessUnit],
	   P.[Project ServiceLine],
	   P.[Project WorkType Display],
	   P.[Project Manager],
	   P.[Project Client Manager], 
	   SUBSTRING(B.Month_Year, 1, 4) [Backlog Year] ,	   SUBSTRING(B.Month_Year, 5, 2) [Backlog Month],
	   REPLACE(D.MonthYear, '-', ' ') [Backlog MonthYear],
	   CASE 
		WHEN SUBSTRING(B.Month_Year, 5, 2) >= 10 THEN SUBSTRING(Month_Year, 1, 4)+1
		ELSE SUBSTRING(B.Month_Year, 1, 4)
	   END [Backlog Fiscal Year],
	   CASE
		WHEN SUBSTRING(B.Month_Year, 5, 2) IN ('01','02','03') THEN '2'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('04','05','06') THEN '3'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('07','08','09') THEN '4'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('10','11','12') THEN '1'
	   END [Backlog Fiscal Quarter],
	   CASE 
			WHEN B.BacklogMonth < DATEPART(MONTH, GETDATE()) THEN CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR,DATEADD(YEAR, 1,GETDATE())) AS VARCHAR) AS DATE)
			ELSE CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR) AS DATE)
	   END [Backlog FirstDayOfMonthAndYear Date],
	   P.ProjectPhaseKey,
	   E.EmployeeKey,
	   NULL, --WorktypeKey Column
	   D.DateKey,
	   P.[Project Client Code] [Backlog Client Code],
       --B.Client_name ,
	   B.[Signature] [Backlog Modified By],
       B.Last_change_date [Backlog Modified Date],
       --B.Proj_name ,
	   P.[Project Phase Code],
	   P.[Project Phase Name],
       --B.ResponsibleCompanyName ,
       --B.ResponsibleOrganizationName ,
       --B.Proj_type ,
       --B.Prac_area ,
       B.Acct_team [Backlog Account Team],
       B.Fee_contract [Backlog Fee Contract] ,
       B.Rem_budget [Backlog Remaining Budget],
       B.Req_fee_adj [Backlog Fee Adjustment],
       B.Tot_fee_adj [Backlog Total Fee Adjustment],
       B.Cur_mo_act [Backlog Current Month Activity],
       B.BacklogMonth [Backlog Month Number],
       B.MonthName [Backlog Month Name],
       B.Amount [Backlog Amount]
--INTO dbo.FactBacklog
FROM dbo.fRADAR_Backlog_report_vertical(7) B
JOIN dbo.DimProjectPhase P
  ON P.[Project Code] = B.Proj_code
 AND P.[Project Phase Code] = '****'
LEFT JOIN dbo.DimEmployee E
  ON E.[Employee Login] = ISNULL(B.Signature, 'NA')
 AND E.[Current]=1
LEFT JOIN dbo.DimDate D
  --ON D.Date = ISNULL(CAST(B.Last_change_date AS DATE), '1-1-1753')
  ON D.Date = CAST(SUBSTRING(B.Month_year, 5, 2) + '-01' + '-' +SUBSTRING(B.Month_year, 1, 4) AS DATE)
 ORDER BY P.[Project Code], B.[MonthName] DESC;

/* 8 Months ago*/
INSERT dbo.FactBacklog
		( Proj_code ,
		  [Backlog Project Name],
		  [Backlog Project Fee Budget],
		  [Backlog Company Name],
		  [Backlog Business Unit],
		  [Backlog ServiceLine],
		  [Backlog Project Worktype],
		  [Backlog Project Manager],
		  [Backlog Project Client Manager],
          [Backlog Year] ,
          [Backlog Month] ,
          [Backlog MonthYear] ,
          [Backlog Fiscal Year] ,
          [Backlog Fiscal Quarter] ,
		  [Backlog FirstDayOfMonthAndYear Date],
          ProjectPhaseKey ,
          EmployeeKey ,
          WorktypeKey ,
		  --PhaseServiceLineKey,
          DateKey ,
          [Backlog Client Code] ,
          [Backlog Modified By] ,
          [Backlog Modified Date] ,
          [Project Phase Code] ,
          [Project Phase Name] ,
          [Backlog Account Team] ,
          [Backlog Fee Contract] ,
          [Backlog Remaining Budget] ,
          [Backlog Fee Adjustment] ,
          [Backlog Total Fee Adjustment] ,
          [Backlog Current Month Activity] ,
          [Backlog Month Number] ,
          [Backlog Month Name] ,
          [Backlog Amount]
        )
SELECT B.Proj_code ,
	   P.[Project Name],
	   P.[Project Fee Budget],
	   P.[Project Company Name],
	   P.[Project BusinessUnit],
	   P.[Project ServiceLine],
	   P.[Project WorkType Display],
	   P.[Project Manager],
	   P.[Project Client Manager], 
	   SUBSTRING(B.Month_Year, 1, 4) [Backlog Year] ,	   SUBSTRING(B.Month_Year, 5, 2) [Backlog Month],
	   REPLACE(D.MonthYear, '-', ' ') [Backlog MonthYear],
	   CASE 
		WHEN SUBSTRING(B.Month_Year, 5, 2) >= 10 THEN SUBSTRING(Month_Year, 1, 4)+1
		ELSE SUBSTRING(B.Month_Year, 1, 4)
	   END [Backlog Fiscal Year],
	   CASE
		WHEN SUBSTRING(B.Month_Year, 5, 2) IN ('01','02','03') THEN '2'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('04','05','06') THEN '3'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('07','08','09') THEN '4'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('10','11','12') THEN '1'
	   END [Backlog Fiscal Quarter],
	   CASE 
			WHEN B.BacklogMonth < DATEPART(MONTH, GETDATE()) THEN CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR,DATEADD(YEAR, 1,GETDATE())) AS VARCHAR) AS DATE)
			ELSE CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR) AS DATE)
	   END [Backlog FirstDayOfMonthAndYear Date],
	   P.ProjectPhaseKey,
	   E.EmployeeKey,
	   NULL, --WorktypeKey Column
	   D.DateKey,
	   P.[Project Client Code] [Backlog Client Code],
       --B.Client_name ,
	   B.[Signature] [Backlog Modified By],
       B.Last_change_date [Backlog Modified Date],
       --B.Proj_name ,
	   P.[Project Phase Code],
	   P.[Project Phase Name],
       --B.ResponsibleCompanyName ,
       --B.ResponsibleOrganizationName ,
       --B.Proj_type ,
       --B.Prac_area ,
       B.Acct_team [Backlog Account Team],
       B.Fee_contract [Backlog Fee Contract] ,
       B.Rem_budget [Backlog Remaining Budget],
       B.Req_fee_adj [Backlog Fee Adjustment],
       B.Tot_fee_adj [Backlog Total Fee Adjustment],
       B.Cur_mo_act [Backlog Current Month Activity],
       B.BacklogMonth [Backlog Month Number],
       B.MonthName [Backlog Month Name],
       B.Amount [Backlog Amount]
--INTO dbo.FactBacklog
FROM dbo.fRADAR_Backlog_report_vertical(8) B
JOIN dbo.DimProjectPhase P
  ON P.[Project Code] = B.Proj_code
 AND P.[Project Phase Code] = '****'
LEFT JOIN dbo.DimEmployee E
  ON E.[Employee Login] = ISNULL(B.Signature, 'NA')
 AND E.[Current]=1
LEFT JOIN dbo.DimDate D
  --ON D.Date = ISNULL(CAST(B.Last_change_date AS DATE), '1-1-1753')
  ON D.Date = CAST(SUBSTRING(B.Month_year, 5, 2) + '-01' + '-' +SUBSTRING(B.Month_year, 1, 4) AS DATE)
 ORDER BY P.[Project Code], B.[MonthName] DESC;

/* 9 Months ago*/
INSERT dbo.FactBacklog
		( Proj_code ,
		  [Backlog Project Name],
		  [Backlog Project Fee Budget],
		  [Backlog Company Name],
		  [Backlog Business Unit],
		  [Backlog ServiceLine],
		  [Backlog Project Worktype],
		  [Backlog Project Manager],
		  [Backlog Project Client Manager],
          [Backlog Year] ,
          [Backlog Month] ,
          [Backlog MonthYear] ,
          [Backlog Fiscal Year] ,
          [Backlog Fiscal Quarter] ,
		  [Backlog FirstDayOfMonthAndYear Date],
          ProjectPhaseKey ,
          EmployeeKey ,
          WorktypeKey ,
		  --PhaseServiceLineKey,
          DateKey ,
          [Backlog Client Code] ,
          [Backlog Modified By] ,
          [Backlog Modified Date] ,
          [Project Phase Code] ,
          [Project Phase Name] ,
          [Backlog Account Team] ,
          [Backlog Fee Contract] ,
          [Backlog Remaining Budget] ,
          [Backlog Fee Adjustment] ,
          [Backlog Total Fee Adjustment] ,
          [Backlog Current Month Activity] ,
          [Backlog Month Number] ,
          [Backlog Month Name] ,
          [Backlog Amount]
        )
SELECT B.Proj_code ,
	   P.[Project Name],
	   P.[Project Fee Budget],
	   P.[Project Company Name],
	   P.[Project BusinessUnit],
	   P.[Project ServiceLine],
	   P.[Project WorkType Display],
	   P.[Project Manager],
	   P.[Project Client Manager], 
	   SUBSTRING(B.Month_Year, 1, 4) [Backlog Year] ,	   SUBSTRING(B.Month_Year, 5, 2) [Backlog Month],
	   REPLACE(D.MonthYear, '-', ' ') [Backlog MonthYear],
	   CASE 
		WHEN SUBSTRING(B.Month_Year, 5, 2) >= 10 THEN SUBSTRING(Month_Year, 1, 4)+1
		ELSE SUBSTRING(B.Month_Year, 1, 4)
	   END [Backlog Fiscal Year],
	   CASE
		WHEN SUBSTRING(B.Month_Year, 5, 2) IN ('01','02','03') THEN '2'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('04','05','06') THEN '3'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('07','08','09') THEN '4'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('10','11','12') THEN '1'
	   END [Backlog Fiscal Quarter],
	   CASE 
			WHEN B.BacklogMonth < DATEPART(MONTH, GETDATE()) THEN CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR,DATEADD(YEAR, 1,GETDATE())) AS VARCHAR) AS DATE)
			ELSE CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR) AS DATE)
	   END [Backlog FirstDayOfMonthAndYear Date],
	   P.ProjectPhaseKey,
	   E.EmployeeKey,
	   NULL, --WorktypeKey Column
	   D.DateKey,
	   P.[Project Client Code] [Backlog Client Code],
       --B.Client_name ,
	   B.[Signature] [Backlog Modified By],
       B.Last_change_date [Backlog Modified Date],
       --B.Proj_name ,
	   P.[Project Phase Code],
	   P.[Project Phase Name],
       --B.ResponsibleCompanyName ,
       --B.ResponsibleOrganizationName ,
       --B.Proj_type ,
       --B.Prac_area ,
       B.Acct_team [Backlog Account Team],
       B.Fee_contract [Backlog Fee Contract] ,
       B.Rem_budget [Backlog Remaining Budget],
       B.Req_fee_adj [Backlog Fee Adjustment],
       B.Tot_fee_adj [Backlog Total Fee Adjustment],
       B.Cur_mo_act [Backlog Current Month Activity],
       B.BacklogMonth [Backlog Month Number],
       B.MonthName [Backlog Month Name],
       B.Amount [Backlog Amount]
--INTO dbo.FactBacklog
FROM dbo.fRADAR_Backlog_report_vertical(9) B
JOIN dbo.DimProjectPhase P
  ON P.[Project Code] = B.Proj_code
 AND P.[Project Phase Code] = '****'
LEFT JOIN dbo.DimEmployee E
  ON E.[Employee Login] = ISNULL(B.Signature, 'NA')
 AND E.[Current]=1
LEFT JOIN dbo.DimDate D
  --ON D.Date = ISNULL(CAST(B.Last_change_date AS DATE), '1-1-1753')
  ON D.Date = CAST(SUBSTRING(B.Month_year, 5, 2) + '-01' + '-' +SUBSTRING(B.Month_year, 1, 4) AS DATE)
 ORDER BY P.[Project Code], B.[MonthName] DESC;

/* 10 Months ago*/
INSERT dbo.FactBacklog
		( Proj_code ,
		  [Backlog Project Name],
		  [Backlog Project Fee Budget],
		  [Backlog Company Name],
		  [Backlog Business Unit],
		  [Backlog ServiceLine],
		  [Backlog Project Worktype],
		  [Backlog Project Manager],
		  [Backlog Project Client Manager],
          [Backlog Year] ,
          [Backlog Month] ,
          [Backlog MonthYear] ,
          [Backlog Fiscal Year] ,
          [Backlog Fiscal Quarter] ,
		  [Backlog FirstDayOfMonthAndYear Date],
          ProjectPhaseKey ,
          EmployeeKey ,
          WorktypeKey ,
		  --PhaseServiceLineKey,
          DateKey ,
          [Backlog Client Code] ,
          [Backlog Modified By] ,
          [Backlog Modified Date] ,
          [Project Phase Code] ,
          [Project Phase Name] ,
          [Backlog Account Team] ,
          [Backlog Fee Contract] ,
          [Backlog Remaining Budget] ,
          [Backlog Fee Adjustment] ,
          [Backlog Total Fee Adjustment] ,
          [Backlog Current Month Activity] ,
          [Backlog Month Number] ,
          [Backlog Month Name] ,
          [Backlog Amount]
        )
SELECT B.Proj_code ,
	   P.[Project Name],
	   P.[Project Fee Budget],
	   P.[Project Company Name],
	   P.[Project BusinessUnit],
	   P.[Project ServiceLine],
	   P.[Project WorkType Display],
	   P.[Project Manager],
	   P.[Project Client Manager], 
	   SUBSTRING(B.Month_Year, 1, 4) [Backlog Year] ,	   SUBSTRING(B.Month_Year, 5, 2) [Backlog Month],
	   REPLACE(D.MonthYear, '-', ' ') [Backlog MonthYear],
	   CASE 
		WHEN SUBSTRING(B.Month_Year, 5, 2) >= 10 THEN SUBSTRING(Month_Year, 1, 4)+1
		ELSE SUBSTRING(B.Month_Year, 1, 4)
	   END [Backlog Fiscal Year],
	   CASE
		WHEN SUBSTRING(B.Month_Year, 5, 2) IN ('01','02','03') THEN '2'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('04','05','06') THEN '3'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('07','08','09') THEN '4'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('10','11','12') THEN '1'
	   END [Backlog Fiscal Quarter],
	   CASE 
			WHEN B.BacklogMonth < DATEPART(MONTH, GETDATE()) THEN CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR,DATEADD(YEAR, 1,GETDATE())) AS VARCHAR) AS DATE)
			ELSE CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR) AS DATE)
	   END [Backlog FirstDayOfMonthAndYear Date],
	   P.ProjectPhaseKey,
	   E.EmployeeKey,
	   NULL, --WorktypeKey Column
	   D.DateKey,
	   P.[Project Client Code] [Backlog Client Code],
       --B.Client_name ,
	   B.[Signature] [Backlog Modified By],
       B.Last_change_date [Backlog Modified Date],
       --B.Proj_name ,
	   P.[Project Phase Code],
	   P.[Project Phase Name],
       --B.ResponsibleCompanyName ,
       --B.ResponsibleOrganizationName ,
       --B.Proj_type ,
       --B.Prac_area ,
       B.Acct_team [Backlog Account Team],
       B.Fee_contract [Backlog Fee Contract] ,
       B.Rem_budget [Backlog Remaining Budget],
       B.Req_fee_adj [Backlog Fee Adjustment],
       B.Tot_fee_adj [Backlog Total Fee Adjustment],
       B.Cur_mo_act [Backlog Current Month Activity],
       B.BacklogMonth [Backlog Month Number],
       B.MonthName [Backlog Month Name],
       B.Amount [Backlog Amount]
--INTO dbo.FactBacklog
FROM dbo.fRADAR_Backlog_report_vertical(10) B
JOIN dbo.DimProjectPhase P
  ON P.[Project Code] = B.Proj_code
 AND P.[Project Phase Code] = '****'
LEFT JOIN dbo.DimEmployee E
  ON E.[Employee Login] = ISNULL(B.Signature, 'NA')
 AND E.[Current]=1
LEFT JOIN dbo.DimDate D
  --ON D.Date = ISNULL(CAST(B.Last_change_date AS DATE), '1-1-1753')
  ON D.Date = CAST(SUBSTRING(B.Month_year, 5, 2) + '-01' + '-' +SUBSTRING(B.Month_year, 1, 4) AS DATE)
 ORDER BY P.[Project Code], B.[MonthName] DESC;

/* 11 Months ago*/
INSERT dbo.FactBacklog
		( Proj_code ,
		  [Backlog Project Name],
		  [Backlog Project Fee Budget],
		  [Backlog Company Name],
		  [Backlog Business Unit],
		  [Backlog ServiceLine],
		  [Backlog Project Worktype],
		  [Backlog Project Manager],
		  [Backlog Project Client Manager],
          [Backlog Year] ,
          [Backlog Month] ,
          [Backlog MonthYear] ,
          [Backlog Fiscal Year] ,
          [Backlog Fiscal Quarter] ,
		  [Backlog FirstDayOfMonthAndYear Date],
          ProjectPhaseKey ,
          EmployeeKey ,
          WorktypeKey ,
		  --PhaseServiceLineKey,
          DateKey ,
          [Backlog Client Code] ,
          [Backlog Modified By] ,
          [Backlog Modified Date] ,
          [Project Phase Code] ,
          [Project Phase Name] ,
          [Backlog Account Team] ,
          [Backlog Fee Contract] ,
          [Backlog Remaining Budget] ,
          [Backlog Fee Adjustment] ,
          [Backlog Total Fee Adjustment] ,
          [Backlog Current Month Activity] ,
          [Backlog Month Number] ,
          [Backlog Month Name] ,
          [Backlog Amount]
        )
SELECT B.Proj_code ,
	   P.[Project Name],
	   P.[Project Fee Budget],
	   P.[Project Company Name],
	   P.[Project BusinessUnit],
	   P.[Project ServiceLine],
	   P.[Project WorkType Display],
	   P.[Project Manager],
	   P.[Project Client Manager],
	   SUBSTRING(B.Month_Year, 1, 4) [Backlog Year] ,	   SUBSTRING(B.Month_Year, 5, 2) [Backlog Month],
	   REPLACE(D.MonthYear, '-', ' ') [Backlog MonthYear],
	   CASE 
		WHEN SUBSTRING(B.Month_Year, 5, 2) >= 10 THEN SUBSTRING(Month_Year, 1, 4)+1
		ELSE SUBSTRING(B.Month_Year, 1, 4)
	   END [Backlog Fiscal Year],
	   CASE
		WHEN SUBSTRING(B.Month_Year, 5, 2) IN ('01','02','03') THEN '2'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('04','05','06') THEN '3'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('07','08','09') THEN '4'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('10','11','12') THEN '1'
	   END [Backlog Fiscal Quarter],
	   CASE 
			WHEN B.BacklogMonth < DATEPART(MONTH, GETDATE()) THEN CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR,DATEADD(YEAR, 1,GETDATE())) AS VARCHAR) AS DATE)
			ELSE CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR) AS DATE)
	   END [Backlog FirstDayOfMonthAndYear Date],
	   P.ProjectPhaseKey,
	   E.EmployeeKey,
	   NULL, --WorktypeKey Column
	   D.DateKey,
	   P.[Project Client Code] [Backlog Client Code],
       --B.Client_name ,
	   B.[Signature] [Backlog Modified By],
       B.Last_change_date [Backlog Modified Date],
       --B.Proj_name ,
	   P.[Project Phase Code],
	   P.[Project Phase Name],
       --B.ResponsibleCompanyName ,
       --B.ResponsibleOrganizationName ,
       --B.Proj_type ,
       --B.Prac_area ,
       B.Acct_team [Backlog Account Team],
       B.Fee_contract [Backlog Fee Contract] ,
       B.Rem_budget [Backlog Remaining Budget],
       B.Req_fee_adj [Backlog Fee Adjustment],
       B.Tot_fee_adj [Backlog Total Fee Adjustment],
       B.Cur_mo_act [Backlog Current Month Activity],
       B.BacklogMonth [Backlog Month Number],
       B.MonthName [Backlog Month Name],
       B.Amount [Backlog Amount]
--INTO dbo.FactBacklog
FROM dbo.fRADAR_Backlog_report_vertical(11) B
JOIN dbo.DimProjectPhase P
  ON P.[Project Code] = B.Proj_code
 AND P.[Project Phase Code] = '****'
LEFT JOIN dbo.DimEmployee E
  ON E.[Employee Login] = ISNULL(B.Signature, 'NA')
 AND E.[Current]=1
LEFT JOIN dbo.DimDate D
  --ON D.Date = ISNULL(CAST(B.Last_change_date AS DATE), '1-1-1753')
  ON D.Date = CAST(SUBSTRING(B.Month_year, 5, 2) + '-01' + '-' +SUBSTRING(B.Month_year, 1, 4) AS DATE)
 ORDER BY P.[Project Code], B.[MonthName] DESC;

/* 12 Months ago*/
INSERT dbo.FactBacklog
		( Proj_code ,
		  [Backlog Project Name],
		  [Backlog Project Fee Budget],
		  [Backlog Company Name],
		  [Backlog Business Unit],
		  [Backlog ServiceLine],
		  [Backlog Project Worktype],
		  [Backlog Project Manager],
		  [Backlog Project Client Manager],
          [Backlog Year] ,
          [Backlog Month] ,
          [Backlog MonthYear] ,
          [Backlog Fiscal Year] ,
          [Backlog Fiscal Quarter] ,
		  [Backlog FirstDayOfMonthAndYear Date],
          ProjectPhaseKey ,
          EmployeeKey ,
          WorktypeKey ,
		  --PhaseServiceLineKey,
          DateKey ,
          [Backlog Client Code] ,
          [Backlog Modified By] ,
          [Backlog Modified Date] ,
          [Project Phase Code] ,
          [Project Phase Name] ,
          [Backlog Account Team] ,
          [Backlog Fee Contract] ,
          [Backlog Remaining Budget] ,
          [Backlog Fee Adjustment] ,
          [Backlog Total Fee Adjustment] ,
          [Backlog Current Month Activity] ,
          [Backlog Month Number] ,
          [Backlog Month Name] ,
          [Backlog Amount]
        )
SELECT B.Proj_code ,
	   P.[Project Name],
	   P.[Project Fee Budget],
	   P.[Project Company Name],
	   P.[Project BusinessUnit],
	   P.[Project ServiceLine],
	   P.[Project WorkType Display],
	   P.[Project Manager],
	   P.[Project Client Manager], 
	   SUBSTRING(B.Month_Year, 1, 4) [Backlog Year] ,	   SUBSTRING(B.Month_Year, 5, 2) [Backlog Month],
	   REPLACE(D.MonthYear, '-', ' ') [Backlog MonthYear],
	   CASE 
		WHEN SUBSTRING(B.Month_Year, 5, 2) >= 10 THEN SUBSTRING(Month_Year, 1, 4)+1
		ELSE SUBSTRING(B.Month_Year, 1, 4)
	   END [Backlog Fiscal Year],
	   CASE
		WHEN SUBSTRING(B.Month_Year, 5, 2) IN ('01','02','03') THEN '2'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('04','05','06') THEN '3'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('07','08','09') THEN '4'
		WHEN SUBSTRING(B.Month_year, 5, 2) IN ('10','11','12') THEN '1'
	   END [Backlog Fiscal Quarter],
	   CASE 
			WHEN B.BacklogMonth < DATEPART(MONTH, GETDATE()) THEN CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR,DATEADD(YEAR, 1,GETDATE())) AS VARCHAR) AS DATE)
			ELSE CAST(CAST(B.BacklogMonth AS VARCHAR) + '-01-' + CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR) AS DATE)
	   END [Backlog FirstDayOfMonthAndYear Date],
	   P.ProjectPhaseKey,
	   E.EmployeeKey,
	   NULL, --WorktypeKey Column
	   D.DateKey,
	   P.[Project Client Code] [Backlog Client Code],
       --B.Client_name ,
	   B.[Signature] [Backlog Modified By],
       B.Last_change_date [Backlog Modified Date],
       --B.Proj_name ,
	   P.[Project Phase Code],
	   P.[Project Phase Name],
       --B.ResponsibleCompanyName ,
       --B.ResponsibleOrganizationName ,
       --B.Proj_type ,
       --B.Prac_area ,
       B.Acct_team [Backlog Account Team],
       B.Fee_contract [Backlog Fee Contract] ,
       B.Rem_budget [Backlog Remaining Budget],
       B.Req_fee_adj [Backlog Fee Adjustment],
       B.Tot_fee_adj [Backlog Total Fee Adjustment],
       B.Cur_mo_act [Backlog Current Month Activity],
       B.BacklogMonth [Backlog Month Number],
       B.MonthName [Backlog Month Name],
       B.Amount [Backlog Amount]
--INTO dbo.FactBacklog
FROM dbo.fRADAR_Backlog_report_vertical(12) B
JOIN dbo.DimProjectPhase P
  ON P.[Project Code] = B.Proj_code
 AND P.[Project Phase Code] = '****'
LEFT JOIN dbo.DimEmployee E
  ON E.[Employee Login] = ISNULL(B.Signature, 'NA')
 AND E.[Current]=1
LEFT JOIN dbo.DimDate D
  --ON D.Date = ISNULL(CAST(B.Last_change_date AS DATE), '1-1-1753')
  ON D.Date = CAST(SUBSTRING(B.Month_year, 5, 2) + '-01' + '-' +SUBSTRING(B.Month_year, 1, 4) AS DATE)
 ORDER BY P.[Project Code], B.[MonthName] DESC;

/*
	UPDATE FactBacklog with WorktypeKey
	JDM 12-29-2016
*/
	UPDATE dbo.FactBacklog
	SET WorktypeKey = W.WorktypeKey
	FROM dbo.FactBacklog B
	JOIN dbo.DimProjectPhase P
	  ON P.ProjectPhaseKey = B.ProjectPhaseKey
	JOIN dbo.DimWorktypes W
	  ON P.[Project WorkType Name] = W.[Worktype Worktype Name]
	 AND P.[Project ServiceLine] = W.[Worktype ServiceLine]
	 AND P.[Project BusinessUnit] = W.[Worktype BusinessUnit];


/*
	UPDATE FactBacklog with Project Timeline info
	JDM 3-21-2018
*/
	UPDATE dbo.FactBacklog
	SET [Backlog Started Months Ago] = R.StartedMonthsAgo,
		[Backlog Timeline In Months] = R.TimelineMonths,
		[Backlog Timeline Used] = CAST(R.StartedMonthsAgo AS DECIMAL)/CAST(R.TimelineMonths AS DECIMAL),
		[Backlog Budget Used] = R.[Pct_Fee Budget Used],
		[Backlog Timeline and Budget Gap] = ((CAST(R.StartedMonthsAgo AS DECIMAL)/CAST(R.TimelineMonths AS DECIMAL)) - R.[Pct_Fee Budget Used])
		--[Backlog Comments] = R.Backlog_Comments,
		--[Backlog WIP Comments] = R.WIP_Comments
	FROM dbo.FactBacklog B
	JOIN Staging.RADAR_vRPT_ProactiveWriteOffReport R
	  ON B.Proj_code = R.Proj_code
	WHERE R.StartedMonthsAgo IS NOT NULL
	  AND R.TimelineMonths IS NOT NULL
	  AND R.TimelineMonths > 0
	  AND R.StartedMonthsAgo > 0

	UPDATE dbo.FactBacklog
	SET [Backlog Comments] = BC.Comments,
		[Backlog WIP Comments] = R.WIP_Comments
	FROM dbo.FactBacklog B
	LEFT JOIN Staging.RADAR_vRPT_ProactiveWriteOffReport R
	  ON B.Proj_code = R.Proj_code
	JOIN Staging.RADAR_Backlog_Comments BC
	  ON  B.Proj_code = BC.Proj_code

END

--EXEC dbo.USP_02_A_Build_Dims_And_Facts
