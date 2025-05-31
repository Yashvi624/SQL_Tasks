
CREATE FUNCTION Format_Date(@InputDate DateTime)
RETURNS varchar(10)
AS 
BEGIN
RETURN CONVERT(VARCHAR(10), @InputDate, 101);
END;
GO

SELECT dbo.Format_Date('2006-11-21 23:34:05.920') AS FormattedDate;

GO
CREATE FUNCTION Format_Date1(@InputDate DateTime)
RETURNS varchar(10)
AS
BEGIN 
RETURN CONVERT(VARCHAR(10),@InputDate,112)
END;
GO

SELECT dbo.Format_Date1('2006-11-21 23:34:05.920') AS FormattedDate;

