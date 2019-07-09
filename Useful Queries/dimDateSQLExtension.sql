USE [Xcenda_DW]
GO

IF OBJECT_ID('tempdb..#dim') IS NOT NULL
BEGIN
    DROP TABLE #dim
END


DECLARE @StartDate DATE = '20190929', @NumberOfYears INT = 30;

SET DATEFIRST 7;
SET DATEFORMAT ymd;
--SET LANGUAGE US_ENGLISH;

DECLARE @CutoffDate DATE = DATEADD(YEAR, @NumberOfYears, @StartDate);



CREATE TABLE #dim(
	[ShortDate] date NULL,
	[DateKey] AS CAST(REPLACE([ShortDate], '-','') AS INT),
	[Date] [datetime] NULL,
	[PeriodEndDate] [datetime] NULL,
	[FullDateUK] AS CONVERT(CHAR(10),  [date], 111),
	--[FullDateUSA] [char](10) NULL,
	[FullDateUSA] AS CONVERT(CHAR(10),  [date], 101),
	[DayOfMonth] [varchar](2) NULL,
	[DaySuffix] [varchar](4) NULL,
	[DayName] [varchar](9) NULL,
	[DayOfWeekUSA] [char](1) NULL,
	[DayOfWeekUK] [char](1) NULL,
	[DayOfWeekInMonth] [varchar](2) NULL,
	[DayOfWeekInYear] [varchar](2) NULL,
	[DayOfQuarter] [varchar](3) NULL,
	[DayOfYear] [varchar](3) NULL,
	[WeekOfMonth] [varchar](1) NULL,
	[WeekOfQuarter] [varchar](2) NULL,
	[WeekOfYear] [varchar](2) NULL,
	[Month] [varchar](2) NULL,
	[MonthName] [varchar](9) NULL,
	[MonthOfQuarter] [varchar](2) NULL,
	[Quarter] [char](1) NULL,
	[QuarterName] [varchar](9) NULL,
	[Year] [char](4) NULL,
	[YearName] [char](7) NULL,
	[MonthYear] [char](10) NULL,
	[MMYYYY] [char](6) NULL,
	[YYYYMM] [char](6) NULL,
	[FirstDayOfMonth] [date] NULL,
	[LastDayOfMonth] [date] NULL,
	[FirstDayOfQuarter] [date] NULL,
	[LastDayOfQuarter] [date] NULL,
	[FirstDayOfYear] AS CONVERT(DATE, DATEADD(YEAR,  DATEDIFF(YEAR,  0, [Date]), 0)),
	[LastDayOfYear] [date] NULL,
	[WorkDayHours] [int] NULL,
	[WorkWeekHours] AS 40,
	[WorkQuarterHours] AS 520,
	[WorkYearHours] AS 2080,
	[IsHolidayUSA] [bit] NULL,
	[IsWeekday] [bit] NULL,
	[IsEndOfMonth] [bit] NULL,
	[HolidayUSA] [varchar](50) NULL,
	[IsHolidayUK] [bit] NULL,
	[HolidayUK] [varchar](50) NULL,
	[FiscalDayOfYear] [varchar](3) NULL,
	[FiscalWeekOfYear] [varchar](3) NULL,
	[FiscalMonth] [varchar](2) NULL,
	[FiscalQuarter] [varchar](1) NULL,
	[FiscalQuarterName] [varchar](9) NULL,
	[FiscalYear] [varchar](4) NULL,
	[FiscalYearName] [varchar](7) NULL,
	[FiscalMonthYear] [varchar](10) NULL,
	[FiscalMMYYYY] [varchar](6) NULL,
	[FiscalFirstDayOfMonth] [date] NULL,
	[FiscalLastDayOfMonth] [date] NULL,
	[FiscalFirstDayOfQuarter] [date] NULL,
	[FiscalLastDayOfQuarter] [date] NULL,
	[FiscalFirstDayOfYear] [date] NULL,
	[FiscalLastDayOfYear] [date] NULL);

INSERT #dim([ShortDate]) 
SELECT d
FROM
(
  SELECT d = DATEADD(DAY, rn - 1, @StartDate)
  FROM 
  (
    SELECT TOP (DATEDIFF(DAY, @StartDate, @CutoffDate)) 
      rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
    FROM sys.all_objects AS s1
    CROSS JOIN sys.all_objects AS s2
    ORDER BY s1.[object_id]
  ) AS x
) AS y;

UPDATE #dim
SET [Date] = CAST([ShortDate] AS datetime)

UPDATE #dim
SET [PeriodEndDate] = DATEADD(DAY, 7 - DATEPART(WEEKDAY, [Date]), [Date])

UPDATE #dim
SET [WeekOfYear] = DATEPART(wk, [Date])

UPDATE #dim
SET [Month] = DATEPART(m, [Date])

UPDATE #dim
SET [Quarter] = DATEPART(q, [Date])

UPDATE #dim
SET [DayOfYear] = DATEPART(dy, [Date])

UPDATE #dim
SET [DayOfMonth] = DATEPART(d, [Date])

UPDATE #dim
SET [Year] = DATEPART(yyyy, [Date])

UPDATE #dim
SET [YearName] = CONCAT('CY ', [Year])

UPDATE #dim
SET [DayName] = DATENAME(dw, [Date]) 

UPDATE #dim
SET [DaySuffix] = CASE 
	WHEN [DayOfMonth] LIKE ('%1') AND [DayOfMonth] <> 11 THEN CONCAT([DayOfMonth], 'st')
	WHEN [DayOfMonth] LIKE ('%2') AND [DayOfMonth] <> 12 THEN CONCAT([DayOfMonth], 'nd')
	WHEN [DayOfMonth] LIKE ('%3') AND [DayOfMonth] <> 13 THEN CONCAT([DayOfMonth], 'rd')
	WHEN [DayOfMonth] NOT LIKE ('%1') OR [DayOfMonth] NOT LIKE ('%2') OR [DayOfMonth] NOT LIKE ('%3') THEN CONCAT([DayOfMonth], 'th')
	END

UPDATE #dim
SET [DayOfWeekUSA] = DATEPART(DW, [Date]) 

UPDATE #dim
SET [DayOfWeekUK] = CASE DATENAME(DW, [Date])
             when 'Monday' then 1
             when 'Tuesday' then 2
             when 'Wednesday' then 3
             when 'Thursday' then 4
             when 'Friday' then 5
             when 'Saturday' then 6
             when 'Sunday' then 7
        end

UPDATE #dim
SET [DayOfWeekInMonth] = DATEPART(WK, [Date]) 


UPDATE #dim
SET [DayOfWeekInYear] = DATEPART(WEEK, [Date]) 
/*
UPDATE #dim
SET [DayOfQuarter] = DATEDIFF(DD,DATEADD(Q,DATEDIFF(Q,0,@StartDate),0),[Date]) + 1 
*/
UPDATE #dim
SET [MonthName] = DATENAME(M, [Date])

UPDATE #dim
SET [QuarterName] = CASE [Quarter]
             when 1 then 'First'
             when 2 then 'Second'
             when 3 then 'Third'
             when 4 then 'Fourth'
        end

UPDATE #dim
SET [MonthYear] = CONCAT(LEFT([MonthName], 3), '-',  [Year])

UPDATE #dim
SET [MMYYYY] = CONVERT(CHAR(6), LEFT(FullDateUSA, 2)    + LEFT(DateKey, 4))

UPDATE #dim
SET [YYYYMM] = CONVERT(CHAR(6), LEFT(DateKey, 4)    + LEFT(FullDateUSA, 2))

UPDATE #dim
SET FirstDayOfMonth = CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, [date]), 0))

UPDATE #dim
SET IsWeekday = CASE WHEN [DayOfWeekUSA] NOT IN (1,7) THEN 1 ELSE 0 END

UPDATE #dim
SET WorkDayHours = CASE WHEN [DayOfWeekUSA] NOT IN (1,7) THEN 8 ELSE 0 END

UPDATE #dim
SET IsHolidayUSA = CASE WHEN IsHolidayUSA IS NULL THEN 0 END

/*Update HOLIDAY fields of UK as per Govt. Declaration of National Holiday*/
	
-- Good Friday  April 18 
	UPDATE #dim
		SET HolidayUK = 'Good Friday'
	WHERE [Month] = 4 AND [DayOfMonth]  = 18

-- Easter Monday  April 21 
	UPDATE #dim
		SET HolidayUK = 'Easter Monday'
	WHERE [Month] = 4 AND [DayOfMonth]  = 21

-- Early May Bank Holiday   May 5 
   UPDATE #dim
		SET HolidayUK = 'Early May Bank Holiday'
	WHERE [Month] = 5 AND [DayOfMonth]  = 5

-- Spring Bank Holiday  May 26 
	UPDATE #dim
		SET HolidayUK = 'Spring Bank Holiday'
	WHERE [Month] = 5 AND [DayOfMonth]  = 26

-- Summer Bank Holiday  August 25 
    UPDATE #dim
		SET HolidayUK = 'Summer Bank Holiday'
	WHERE [Month] = 8 AND [DayOfMonth]  = 25

-- Boxing Day  December 26  	
    UPDATE #dim
		SET HolidayUK = 'Boxing Day'
	WHERE [Month] = 12 AND [DayOfMonth]  = 26	

--CHRISTMAS
	UPDATE #dim
		SET HolidayUK = 'Christmas Day'
	WHERE [Month] = 12 AND [DayOfMonth]  = 25

--New Years Day
	UPDATE #dim
		SET HolidayUK  = 'New Year''s Day'
	WHERE [Month] = 1 AND [DayOfMonth] = 1

--Update flag for UK Holidays 1= Holiday, 0=No Holiday
	
	UPDATE #dim
		SET IsHolidayUK  = CASE WHEN HolidayUK   IS NULL
		THEN 0 WHEN HolidayUK   IS NOT NULL THEN 1 END


	/********************************************************************************************/


;with tbc as (
	select
	  [Date]
	  ,[DayOfQuarter] = DATEDIFF(dd, DATEADD(q, DATEDIFF(q, 0, [Date]),0), [Date]) +1
      ,[WeekOfMonth] = CONVERT(TINYINT, DENSE_RANK() OVER (PARTITION BY [Year], [Month] ORDER BY [WeekOfYear]))
      ,[WeekOfQuarter] = DATEDIFF(wk, DATEADD(q, DATEDIFF(q, 0, [Date]),0), [Date]) +1
      ,[MonthOfQuarter] = DATEDIFF(mm, DATEADD(q, DATEDIFF(q, 0, [Date]),0), [Date]) +1
	  ,[LastDayOfMonth] = CAST(MAX([Date]) OVER (PARTITION BY [Year], [Month]) AS DATE)
      ,[FirstDayOfQuarter] = CAST(MIN([Date]) OVER (PARTITION BY [Year], [Quarter]) AS DATE)
      ,[LastDayOfQuarter] = CAST(MAX([Date]) OVER (PARTITION BY [Year], [Quarter]) AS DATE)
      ,[LastDayOfYear] = CAST(MAX([Date]) OVER (PARTITION BY [Year]) AS DATE)
      ,[IsEndOfMonth] = CASE WHEN CAST([Date] AS DATE) = CAST(MAX([Date]) OVER (PARTITION BY [Year], [Month]) AS DATE) THEN 1 ELSE 0 END
		from #dim
		)

UPDATE #dim
SET [DayOfQuarter] = t.[DayOfQuarter],
[WeekOfMonth] = t.[WeekOfMonth],
[WeekOfQuarter] =t.[WeekOfQuarter],
[MonthOfQuarter] = t.[MonthOfQuarter],
[LastDayOfMonth] = t.[LastDayOfMonth],
[FirstDayOfQuarter] = t.[FirstDayOfQuarter],
[LastDayOfQuarter] = t.[LastDayOfQuarter],
[LastDayOfYear] = t.[LastDayOfYear],
[IsEndOfMonth] = t.[IsEndOfMonth]
FROM tbc t
  FULL JOIN #dim b ON CAST(b.Date AS date) = CAST(t.[Date] AS DATE)
		
;WITH tbh AS 
(
  SELECT /* DateKey, */ [Date], [IsHolidayUSA], [HolidayUSA], FirstDayOfYear,
    [DayOfWeekInMonth], [MonthName], [DayName], [DayOfMonth],
    LastDOWInMonth = ROW_NUMBER() OVER 
    (
      PARTITION BY FirstDayOfMonth, [DayName]
      ORDER BY [Date] DESC
    )
  FROM #dim
)
UPDATE tbh SET [IsHolidayUSA] = 1, [HolidayUSA] = CASE
  WHEN ([Date] = FirstDayOfYear) 
    THEN 'New Year''s Day'
  WHEN ([DayOfWeekInMonth] = 3 AND [MonthName] = 'January' AND [DayName] = 'Monday')
    THEN 'Martin Luther King Day'    -- (3rd Monday in January)
  WHEN ([DayOfWeekInMonth] = 3 AND [MonthName] = 'February' AND [DayName] = 'Monday')
    THEN 'President''s Day'          -- (3rd Monday in February)
  WHEN ([LastDOWInMonth] = 1 AND [MonthName] = 'May' AND [DayName] = 'Monday')
    THEN 'Memorial Day'              -- (last Monday in May)
  WHEN ([MonthName] = 'July' AND [DayOfMonth] = 4)
    THEN 'Independence Day'          -- (July 4th)
  WHEN ([DayOfWeekInMonth] = 1 AND [MonthName] = 'September' AND [DayName] = 'Monday')
    THEN 'Labour Day'                -- (first Monday in September)
  WHEN ([DayOfWeekInMonth] = 2 AND [MonthName] = 'October' AND [DayName] = 'Monday')
    THEN 'Columbus Day'              -- Columbus Day (second Monday in October)
  WHEN ([MonthName] = 'November' AND [DayOfMonth] = 11)
    THEN 'Veterans'' Day'            -- Veterans' Day (November 11th)
  WHEN ([DayOfWeekInMonth] = 4 AND [MonthName] = 'November' AND [DayName] = 'Thursday')
    THEN 'Thanksgiving Day'          -- Thanksgiving Day (fourth Thursday in November)
  WHEN ([MonthName] = 'December' AND [DayOfMonth] = 25)
    THEN 'Christmas Day'
  END
  WHERE 
  ([Date] = FirstDayOfYear)
  OR ([DayOfWeekInMonth] = 3     AND [MonthName] = 'January'   AND [DayName] = 'Monday')
  OR ([DayOfWeekInMonth] = 3     AND [MonthName] = 'February'  AND [DayName] = 'Monday')
  OR ([LastDOWInMonth] = 1 AND [MonthName] = 'May'       AND [DayName] = 'Monday')
  OR ([MonthName] = 'July' AND [DayOfMonth] = 4)
  OR ([DayOfWeekInMonth] = 1     AND [MonthName] = 'September' AND [DayName] = 'Monday')
  OR ([DayOfWeekInMonth] = 2     AND [MonthName] = 'October'   AND [DayName] = 'Monday')
  OR ([MonthName] = 'November' AND [DayOfMonth] = 11)
  OR ([DayOfWeekInMonth] = 4     AND [MonthName] = 'November' AND [DayName] = 'Thursday')
  OR ([MonthName] = 'December' AND [DayOfMonth] = 25);

WITH fy AS (
SELECT MIN([Date]) AS FiscalFirstDayOfYear, YEAR(MIN([Date])) +1 AS FiscalYear 
FROM #dim
WHERE MONTH(PeriodEndDate) = 10
GROUP BY [Year], MONTH(PeriodEndDate)
)
UPDATE #dim
SET [FiscalFirstDayOfYear] = CASE WHEN b.[Date] >= f.FiscalFirstDayOfYear THEN CAST(f.FiscalFirstDayOfYear AS DATE) END
FROM fy f
  FULL JOIN #dim b ON CAST(b.Date AS date) = CAST(f.FiscalFirstDayOfYear AS DATE);

WITH CTE AS(
    SELECT DateKey,
           FiscalFirstDayOfYear,
           COUNT(CASE WHEN FiscalFirstDayOfYear IS NOT NULL THEN 1 END) OVER (ORDER BY DateKey
                                                               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Grp
    FROM #dim p), CTE2 as(
SELECT DateKey,
       FiscalFirstDayOfYear,
       MIN(FiscalFirstDayOfYear) OVER (PARTITION BY grp) AS ff_date
FROM CTE c)
UPDATE #dim
SET FiscalFirstDayOfYear = c2.ff_date
FROM CTE2 c2
JOIN #dim d
 ON d.DateKey = c2.DateKey

 /*
 	/***************************************************************************
	The following section needs to be populated for defining the fiscal calendar
	***************************************************************************/

	DECLARE
		@dtFiscalYearStart SMALLDATETIME = 'October 1, 1995',
		@FiscalYear INT = 1995,
		@LastYear INT = 2049,
		@FirstLeapYearInPeriod INT = 1996

	/*****************************************************************************************/

	DECLARE
		@iTemp INT,
		@LeapWeek INT,
		@CurrentDate DATETIME,
		@FiscalDayOfYear INT,
		@FiscalWeekOfYear INT,
		@FiscalMonth INT,
		@FiscalQuarter INT,
		@FiscalQuarterName VARCHAR(10),
		@FiscalYearName VARCHAR(7),
		@LeapYear INT,
		@FiscalFirstDayOfYear DATE,
		@FiscalFirstDayOfQuarter DATE,
		@FiscalFirstDayOfMonth DATE,
		@FiscalLastDayOfYear DATE,
		@FiscalLastDayOfQuarter DATE,
		@FiscalLastDayOfMonth DATE

	/*Holds the years that have 455 in last quarter*/

	DECLARE @LeapTable TABLE (leapyear INT)

	/*TABLE to contain the fiscal year calendar*/

	DECLARE @tb TABLE(
		PeriodDate DATETIME,
		[FiscalDayOfYear] VARCHAR(3),
		[FiscalWeekOfYear] VARCHAR(3),
		[FiscalMonth] VARCHAR(2), 
		[FiscalQuarter] VARCHAR(1),
		[FiscalQuarterName] VARCHAR(9),
		[FiscalYear] VARCHAR(4),
		[FiscalYearName] VARCHAR(7),
		[FiscalMonthYear] VARCHAR(10),
		[FiscalMMYYYY] VARCHAR(6),
		[FiscalFirstDayOfMonth] DATE,
		[FiscalLastDayOfMonth] DATE,
		[FiscalFirstDayOfQuarter] DATE,
		[FiscalLastDayOfQuarter] DATE,
		[FiscalFirstDayOfYear] DATE,
		[FiscalLastDayOfYear] DATE)

	/*Populate the table with all leap years*/

	SET @LeapYear = @FirstLeapYearInPeriod
	WHILE (@LeapYear < @LastYear)
		BEGIN
			INSERT INTO @leapTable VALUES (@LeapYear)
			SET @LeapYear = @LeapYear + 5
		END

	/*Initiate parameters before loop*/

	SET @CurrentDate = @dtFiscalYearStart
	SET @FiscalDayOfYear = 1
	SET @FiscalWeekOfYear = 1
	SET @FiscalMonth = 1
	SET @FiscalQuarter = 1
	SET @FiscalWeekOfYear = 1

	IF (EXISTS (SELECT * FROM @LeapTable WHERE @FiscalYear = leapyear))
		BEGIN
			SET @LeapWeek = 1
		END
		ELSE
		BEGIN
			SET @LeapWeek = 0
		END

	/*******************************************************************************************/

	/* Loop on days in interval*/

	WHILE (DATEPART(yy,@CurrentDate) <= @LastYear)
	BEGIN
		
	/*SET fiscal Month*/
		SELECT @FiscalMonth = CASE 
			/*Use this section for a 4-5-4 calendar.  
			Every leap year the result will be a 4-5-5*/
			WHEN @FiscalWeekOfYear BETWEEN 1 AND 4 THEN 1 /*4 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN 5 AND 9 THEN 2 /*5 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN 10 AND 13 THEN 3 /*4 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN 14 AND 17 THEN 4 /*4 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN 18 AND 22 THEN 5 /*5 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN 23 AND 26 THEN 6 /*4 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN 27 AND 30 THEN 7 /*4 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN 31 AND 35 THEN 8 /*5 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN 36 AND 39 THEN 9 /*4 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN 40 AND 43 THEN 10 /*4 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN 44 AND (48+@LeapWeek) THEN 11 
	/*5 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN (49+@LeapWeek) AND (52+@LeapWeek) THEN 12
	/*4 weeks (5 weeks on leap year)*/
			
	/*Use this section for a 4-4-5 calendar.  
	Every leap year the result will be a 4-5-5*/
			/*
			WHEN @FiscalWeekOfYear BETWEEN 1 AND 4 THEN 1 /*4 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN 5 AND 8 THEN 2 /*4 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN 9 AND 13 THEN 3 /*5 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN 14 AND 17 THEN 4 /*4 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN 18 AND 21 THEN 5 /*4 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN 22 AND 26 THEN 6 /*5 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN 27 AND 30 THEN 7 /*4 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN 31 AND 34 THEN 8 /*4 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN 35 AND 39 THEN 9 /*5 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN 40 AND 43 THEN 10 /*4 weeks*/
			WHEN @FiscalWeekOfYear BETWEEN 44 AND _
			(47+@leapWeek) THEN 11 /*4 weeks (5 weeks on leap year)*/
	WHEN @FiscalWeekOfYear BETWEEN (48+@leapWeek) AND (52+@leapWeek) THEN 12 /*5 weeks*/
			*/
		END

		/*SET Fiscal Quarter*/
		SELECT @FiscalQuarter = CASE 
			WHEN @FiscalMonth BETWEEN 1 AND 3 THEN 1
			WHEN @FiscalMonth BETWEEN 4 AND 6 THEN 2
			WHEN @FiscalMonth BETWEEN 7 AND 9 THEN 3
			WHEN @FiscalMonth BETWEEN 10 AND 12 THEN 4
		END
		
		SELECT @FiscalQuarterName = CASE 
			WHEN @FiscalMonth BETWEEN 1 AND 3 THEN 'First'
			WHEN @FiscalMonth BETWEEN 4 AND 6 THEN 'Second'
			WHEN @FiscalMonth BETWEEN 7 AND 9 THEN 'Third'
			WHEN @FiscalMonth BETWEEN 10 AND 12 THEN 'Fourth'
		END
		
		/*Set Fiscal Year Name*/
		SELECT @FiscalYearName = 'FY ' + CONVERT(VARCHAR, @FiscalYear)

		INSERT INTO @tb (PeriodDate, FiscalDayOfYear, FiscalWeekOfYear, 
		fiscalMonth, FiscalQuarter, FiscalQuarterName, FiscalYear, FiscalYearName) VALUES 
		(@CurrentDate, @FiscalDayOfYear, @FiscalWeekOfYear, @FiscalMonth, 
		@FiscalQuarter, @FiscalQuarterName, @FiscalYear, @FiscalYearName)

		/*SET next day*/
		SET @CurrentDate = DATEADD(dd, 1, @CurrentDate)
		SET @FiscalDayOfYear = @FiscalDayOfYear + 1
		SET @FiscalWeekOfYear = ((@FiscalDayOfYear-1) / 7) + 1


		IF (@FiscalWeekOfYear > (52+@LeapWeek))
		BEGIN
			/*Reset a new year*/
			SET @FiscalDayOfYear = 1
			SET @FiscalWeekOfYear = 1
			SET @FiscalYear = @FiscalYear + 1
			IF ( EXISTS (SELECT * FROM @leapTable WHERE @FiscalYear = leapyear))
			BEGIN
				SET @LeapWeek = 1
			END
			ELSE
			BEGIN
				SET @LeapWeek = 0
			END
		END
	END

	/********************************************************************************************/

	/*Set first and last days of the fiscal months*/
	UPDATE @tb
	SET
		FiscalFirstDayOfMonth = minmax.StartDate,
		FiscalLastDayOfMonth = minmax.EndDate
	FROM
	@tb t,
		(
		SELECT FiscalMonth, FiscalQuarter, FiscalYear, 
		MIN(PeriodDate) AS StartDate, MAX(PeriodDate) AS EndDate
		FROM @tb
		GROUP BY FiscalMonth, FiscalQuarter, FiscalYear
		) minmax
	WHERE
		t.FiscalMonth = minmax.FiscalMonth AND
		t.FiscalQuarter = minmax.FiscalQuarter AND
		t.FiscalYear = minmax.FiscalYear 

	/*Set first and last days of the fiscal quarters*/

	UPDATE @tb
	SET
		FiscalFirstDayOfQuarter = minmax.StartDate,
		FiscalLastDayOfQuarter = minmax.EndDate
	FROM
	@tb t,
		(
		SELECT FiscalQuarter, FiscalYear, min(PeriodDate) 
		as StartDate, max(PeriodDate) as EndDate
		FROM @tb
		GROUP BY FiscalQuarter, FiscalYear
		) minmax
	WHERE
		t.FiscalQuarter = minmax.FiscalQuarter AND
		t.FiscalYear = minmax.FiscalYear 

	/*Set first and last days of the fiscal years*/

	UPDATE @tb
	SET
		FiscalFirstDayOfYear = minmax.StartDate,
		FiscalLastDayOfYear = minmax.EndDate
	FROM
	@tb t,
		(
		SELECT FiscalYear, min(PeriodDate) as StartDate, max(PeriodDate) as EndDate
		FROM @tb
		GROUP BY FiscalYear
		) minmax
	WHERE
		t.FiscalYear = minmax.FiscalYear 

	/*Set FiscalYearMonth*/
	UPDATE @tb
	SET
		FiscalMonthYear = 
			CASE FiscalMonth
			WHEN 1 THEN 'Jan'
			WHEN 2 THEN 'Feb'
			WHEN 3 THEN 'Mar'
			WHEN 4 THEN 'Apr'
			WHEN 5 THEN 'May'
			WHEN 6 THEN 'Jun'
			WHEN 7 THEN 'Jul'
			WHEN 8 THEN 'Aug'
			WHEN 9 THEN 'Sep'
			WHEN 10 THEN 'Oct'
			WHEN 11 THEN 'Nov'
			WHEN 12 THEN 'Dec'
			END + '-' + CONVERT(VARCHAR, FiscalYear)

	/*Set FiscalMMYYYY*/
	UPDATE @tb
	SET
		FiscalMMYYYY = RIGHT('0' + CONVERT(VARCHAR, FiscalMonth),2) + CONVERT(VARCHAR, FiscalYear)

	/********************************************************************************************/

	UPDATE #dim
		SET
		FiscalDayOfYear = a.FiscalDayOfYear
		, FiscalWeekOfYear = a.FiscalWeekOfYear
		, FiscalMonth = a.FiscalMonth
		, FiscalQuarter = a.FiscalQuarter
		, FiscalQuarterName = a.FiscalQuarterName
		, FiscalYear = a.FiscalYear
		, FiscalYearName = a.FiscalYearName
		, FiscalMonthYear = a.FiscalMonthYear
		, FiscalMMYYYY = a.FiscalMMYYYY
		, FiscalFirstDayOfMonth = a.FiscalFirstDayOfMonth
		, FiscalLastDayOfMonth = a.FiscalLastDayOfMonth
		, FiscalFirstDayOfQuarter = a.FiscalFirstDayOfQuarter
		, FiscalLastDayOfQuarter = a.FiscalLastDayOfQuarter
		, FiscalFirstDayOfYear = a.FiscalFirstDayOfYear
		, FiscalLastDayOfYear = a.FiscalLastDayOfYear
	FROM @tb a
		FULL JOIN #dim b ON CAST(a.PeriodDate AS date) = b.[Date]

/********************************************************************************/
*/

UPDATE #dim
SET FiscalYear = YEAR(FiscalFirstDayOfYear) +1

;WITH FY AS (
SELECT [FiscalDayOfYear] = DATEDIFF(dd, FiscalFirstDayOfYear, [Date]) +1,
DateKey
FROM #dim)
UPDATE #dim
SET [FiscalDayOfYear] = FY.[FiscalDayOfYear]
FROM FY
JOIN #dim
 ON FY.DateKey = #dim.DateKey

UPDATE #dim
SET [FiscalWeekOfYear] = (([FiscalDayOfYear]-1) / 7) + 1

/*
SELECT 
[FiscalDayOfYear] = DATEDIFF(dd, FiscalFirstDayOfYear, [Date]) +1, 
FiscalFirstDayOfYear,
DateKey,
[Date]
FROM #dim
ORDER BY DATEKEY ASC
*/

DECLARE
@LastYear INT = YEAR(@cutoffdate),
@FirstLeapYearInPeriod INT = 1996

DECLARE 
@LeapTable TABLE (leapyear INT)


	DECLARE
		@iTemp INT,
		@LeapWeek INT,
		@CurrentDate DATETIME,
		@FiscalMonth INT,
		@FiscalQuarter INT,
		@FiscalQuarterName VARCHAR(10),
		@FiscalYearName VARCHAR(7),
		@LeapYear INT,
		@FiscalFirstDayOfQuarter DATE,
		@FiscalFirstDayOfMonth DATE,
		@FiscalLastDayOfYear DATE,
		@FiscalLastDayOfQuarter DATE,
		@FiscalLastDayOfMonth DATE
	/*Populate the table with all leap years*/

	SET @LeapYear = @FirstLeapYearInPeriod
	WHILE (@LeapYear < @LastYear)
		BEGIN
			INSERT INTO @leapTable VALUES (@LeapYear)
			SET @LeapYear = @LeapYear + 5
		END

	/*Initiate parameters before loop*/

	SET @CurrentDate = @StartDate
	SET @FiscalMonth = 1
	SET @FiscalQuarter = 1

	IF (EXISTS (SELECT * FROM @LeapTable JOIN #dim d ON d.FiscalYear = leapyear))
		BEGIN
			SET @LeapWeek = 1
		END
		ELSE
		BEGIN
			SET @LeapWeek = 0
		END

	/*******************************************************************************************/
	/*SET fiscal Month*/
		UPDATE #dim
		SET FiscalMonth = CASE 
			/*Use this section for a 4-5-4 calendar.  
			Every leap year the result will be a 4-5-5*/
			WHEN FiscalWeekOfYear BETWEEN 1 AND 4 THEN 1 /*4 weeks*/
			WHEN FiscalWeekOfYear BETWEEN 5 AND 9 THEN 2 /*5 weeks*/
			WHEN FiscalWeekOfYear BETWEEN 10 AND 13 THEN 3 /*4 weeks*/
			WHEN FiscalWeekOfYear BETWEEN 14 AND 17 THEN 4 /*4 weeks*/
			WHEN FiscalWeekOfYear BETWEEN 18 AND 22 THEN 5 /*5 weeks*/
			WHEN FiscalWeekOfYear BETWEEN 23 AND 26 THEN 6 /*4 weeks*/
			WHEN FiscalWeekOfYear BETWEEN 27 AND 30 THEN 7 /*4 weeks*/
			WHEN FiscalWeekOfYear BETWEEN 31 AND 35 THEN 8 /*5 weeks*/
			WHEN FiscalWeekOfYear BETWEEN 36 AND 39 THEN 9 /*4 weeks*/
			WHEN FiscalWeekOfYear BETWEEN 40 AND 43 THEN 10 /*4 weeks*/
			WHEN FiscalWeekOfYear BETWEEN 44 AND (48+@LeapWeek) THEN 11 
	/*5 weeks*/
			WHEN FiscalWeekOfYear BETWEEN (49+@LeapWeek) AND (52+@LeapWeek) THEN 12
	/*4 weeks (5 weeks on leap year)*/
			END

		/*SET Fiscal Quarter*/
		UPDATE #dim
		SET FiscalQuarter = CASE 
			WHEN FiscalMonth BETWEEN 1 AND 3 THEN 1
			WHEN FiscalMonth BETWEEN 4 AND 6 THEN 2
			WHEN FiscalMonth BETWEEN 7 AND 9 THEN 3
			WHEN FiscalMonth BETWEEN 10 AND 12 THEN 4
		END
		
		UPDATE #dim
		SET FiscalQuarterName = CASE 
			WHEN FiscalMonth BETWEEN 1 AND 3 THEN 'First'
			WHEN FiscalMonth BETWEEN 4 AND 6 THEN 'Second'
			WHEN FiscalMonth BETWEEN 7 AND 9 THEN 'Third'
			WHEN FiscalMonth BETWEEN 10 AND 12 THEN 'Fourth'
		END
		
		/*Set Fiscal Year Name*/
		UPDATE #dim
		SET FiscalYearName = 'FY ' + CONVERT(VARCHAR, FiscalYear)
			

/*Set first and last days of the fiscal months*/
	UPDATE #dim 
	SET
		FiscalFirstDayOfMonth = minmax.StartDate,
		FiscalLastDayOfMonth = minmax.EndDate
	FROM
	#dim t,
		(
		SELECT FiscalMonth, FiscalQuarter, FiscalYear, 
		MIN([Date]) AS StartDate, MAX([Date]) AS EndDate
		FROM #dim
		GROUP BY FiscalMonth, FiscalQuarter, FiscalYear
		) minmax
	WHERE
		t.FiscalMonth = minmax.FiscalMonth AND
		t.FiscalQuarter = minmax.FiscalQuarter AND
		t.FiscalYear = minmax.FiscalYear 

	/*Set first and last days of the fiscal quarters*/

	UPDATE #dim
	SET
		FiscalFirstDayOfQuarter = minmax.StartDate,
		FiscalLastDayOfQuarter = minmax.EndDate
	FROM
	#dim t,
		(
		SELECT FiscalQuarter, FiscalYear, min([Date]) 
		as StartDate, max([Date]) as EndDate
		FROM #dim
		GROUP BY FiscalQuarter, FiscalYear
		) minmax
	WHERE
		t.FiscalQuarter = minmax.FiscalQuarter AND
		t.FiscalYear = minmax.FiscalYear 

	/*Set first and last days of the fiscal years*/

	UPDATE #dim
	SET
		FiscalFirstDayOfYear = minmax.StartDate,
		FiscalLastDayOfYear = minmax.EndDate
	FROM
	#dim t,
		(
		SELECT FiscalYear, min([Date]) as StartDate, max([Date]) as EndDate
		FROM #dim
		GROUP BY FiscalYear
		) minmax
	WHERE
		t.FiscalYear = minmax.FiscalYear 

	/*Set FiscalYearMonth*/
	UPDATE #dim
	SET
		FiscalMonthYear = 
			CASE FiscalMonth
			WHEN 1 THEN 'Jan'
			WHEN 2 THEN 'Feb'
			WHEN 3 THEN 'Mar'
			WHEN 4 THEN 'Apr'
			WHEN 5 THEN 'May'
			WHEN 6 THEN 'Jun'
			WHEN 7 THEN 'Jul'
			WHEN 8 THEN 'Aug'
			WHEN 9 THEN 'Sep'
			WHEN 10 THEN 'Oct'
			WHEN 11 THEN 'Nov'
			WHEN 12 THEN 'Dec'
			END + '-' + CONVERT(VARCHAR, FiscalYear)

	/*Set FiscalMMYYYY*/
	UPDATE #dim
	SET
		FiscalMMYYYY = RIGHT('0' + CONVERT(VARCHAR, FiscalMonth),2) + CONVERT(VARCHAR, FiscalYear)

--insert into DimDate
select [DateKey]
      ,[Date]
      ,[PeriodEndDate]
      ,[FullDateUK]
      ,[FullDateUSA]
      ,[DayOfMonth]
      ,[DaySuffix]
      ,[DayName]
      ,[DayOfWeekUSA]
      ,[DayOfWeekUK]
      ,[DayOfWeekInMonth]
      ,[DayOfWeekInYear]
      ,[DayOfQuarter]
      ,[DayOfYear]
      ,[WeekOfMonth]
      ,[WeekOfQuarter]
      ,[WeekOfYear]
      ,[Month]
      ,[MonthName]
      ,[MonthOfQuarter]
      ,[Quarter]
      ,[QuarterName]
      ,[Year]
      ,[YearName]
      ,[MonthYear]
      ,[MMYYYY]
      ,[YYYYMM]
      ,[FirstDayOfMonth]
      ,[LastDayOfMonth]
      ,[FirstDayOfQuarter]
      ,[LastDayOfQuarter]
      ,[FirstDayOfYear]
      ,[LastDayOfYear]
      ,[WorkDayHours]
      ,[WorkWeekHours]
      ,[WorkQuarterHours]
      ,[WorkYearHours]
      ,[IsHolidayUSA]
      ,[IsWeekday]
      ,[IsEndOfMonth]
      ,[HolidayUSA]
      ,[IsHolidayUK]
      ,[HolidayUK]
      ,[FiscalDayOfYear]
      ,[FiscalWeekOfYear]
      ,[FiscalMonth]
      ,[FiscalQuarter]
      ,[FiscalQuarterName]
      ,[FiscalYear]
      ,[FiscalYearName]
      ,[FiscalMonthYear]
      ,[FiscalMMYYYY]
      ,[FiscalFirstDayOfMonth]
      ,[FiscalLastDayOfMonth]
      ,[FiscalFirstDayOfQuarter]
      ,[FiscalLastDayOfQuarter]
      ,[FiscalFirstDayOfYear]
      ,[FiscalLastDayOfYear]
from #dim
WHERE YEAR = 2020
--WHERE [FiscalYear] IN (2020) and Year = 2019
order by [DateKey] asc


SELECT *
FROM [Xcenda_DW].[dbo].[DimDate]
WHERE FiscalYear = 2020