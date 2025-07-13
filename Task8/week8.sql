CREATE TABLE dbo.DateDimension (
    SKDate INT PRIMARY KEY,
    KeyDate DATE,
    DateValue DATE,
    CalendarDay INT,
    CalendarMonth INT,
    CalendarQuarter INT,
    CalendarYear INT,
    DayNameLong VARCHAR(20),
    DayNameShort VARCHAR(10),
    DayNumberOfWeek INT,
    DayNumberOfYear INT,
    DaySuffix VARCHAR(10),
    FiscalWeek VARCHAR(10),
    FiscalPeriod INT,
    FiscalQuarter VARCHAR(10),
    FiscalYear INT,
    FiscalYearPeriod VARCHAR(10)
);
GO
CREATE PROCEDURE dbo.PopulateDateDimension
    @InputDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartDate DATE = DATEFROMPARTS(YEAR(@InputDate), 1, 1);
    DECLARE @EndDate DATE = DATEFROMPARTS(YEAR(@InputDate), 12, 31);

    ;WITH DateSeries AS (
        SELECT @StartDate AS CurrentDate
        UNION ALL
        SELECT DATEADD(DAY, 1, CurrentDate)
        FROM DateSeries
        WHERE CurrentDate < @EndDate
    )
    INSERT INTO dbo.DateDimension (
        SKDate, KeyDate, DateValue, CalendarDay, CalendarMonth, CalendarQuarter,
        CalendarYear, DayNameLong, DayNameShort, DayNumberOfWeek,
        DayNumberOfYear, DaySuffix, FiscalWeek, FiscalPeriod,
        FiscalQuarter, FiscalYear, FiscalYearPeriod
    )
    SELECT
        CONVERT(INT, FORMAT(CurrentDate, 'yyyyMMdd')) AS SKDate,
        CurrentDate AS KeyDate,
        CurrentDate AS DateValue,
        DATEPART(DAY, CurrentDate) AS CalendarDay,
        DATEPART(MONTH, CurrentDate) AS CalendarMonth,
        DATEPART(QUARTER, CurrentDate) AS CalendarQuarter,
        DATEPART(YEAR, CurrentDate) AS CalendarYear,
        DATENAME(WEEKDAY, CurrentDate) AS DayNameLong,
        LEFT(DATENAME(WEEKDAY, CurrentDate), 3) AS DayNameShort,
        DATEPART(WEEKDAY, CurrentDate) AS DayNumberOfWeek,
        DATEPART(DAYOFYEAR, CurrentDate) AS DayNumberOfYear,
        CAST(DATEPART(DAY, CurrentDate) AS VARCHAR(2)) +
            CASE 
                WHEN DATEPART(DAY, CurrentDate) IN (1, 21, 31) THEN 'st'
                WHEN DATEPART(DAY, CurrentDate) IN (2, 22) THEN 'nd'
                WHEN DATEPART(DAY, CurrentDate) IN (3, 23) THEN 'rd'
                ELSE 'th'
            END AS DaySuffix,
        RIGHT('00' + CAST(DATEPART(WEEK, CurrentDate) AS VARCHAR), 2) AS FiscalWeek,
        DATEPART(MONTH, CurrentDate) AS FiscalPeriod,
        'Q' + CAST(DATEPART(QUARTER, CurrentDate) AS VARCHAR) AS FiscalQuarter,
        DATEPART(YEAR, CurrentDate) AS FiscalYear,
        CAST(DATEPART(YEAR, CurrentDate) AS VARCHAR) + RIGHT('00' + CAST(DATEPART(MONTH, CurrentDate) AS VARCHAR), 2) AS FiscalYearPeriod
    FROM DateSeries
    OPTION (MAXRECURSION 366);
END
GO

EXEC dbo.PopulateDateDimension '2020-07-14';

SELECT * FROM DateDimension