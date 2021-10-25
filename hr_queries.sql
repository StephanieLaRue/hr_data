USE hr_dataset;

-- total employees 
SELECT COUNT(*) AS Employees FROM hr_dataset;

-- absences and performance score
SELECT 
	PerformanceScore, 
	SUM(absences) AS Absences 
FROM hr_dataset 
GROUP BY PerformanceScore;

-- performancescores and number of absences by department
SELECT TOP(100) PERCENT
	PerformanceScore, Department,
	SUM(absences) AS Absences 
FROM hr_dataset 
GROUP BY PerformanceScore, Department
ORDER BY PerformanceScore, Department;

-- % of department
SELECT TOP(100) PERCENT
	PerformanceScore, Department,
	SUM(absences) AS Absences,
	SUM(absences) * 100.0 / SUM(SUM(absences)) OVER () AS Percentage
FROM hr_dataset 
GROUP BY PerformanceScore, Department
ORDER BY PerformanceScore, Department;

SELECT TOP(100) PERCENT
	Department, 
	SUM(absences) * 100.0 / SUM(SUM(absences)) OVER () AS Percentage
FROM hr_dataset 
GROUP BY Department
ORDER BY Percentage desc;

-- % of total absences
SELECT TOP(100) PERCENT
	PerformanceScore, 
	SUM(absences) * 100.0 / SUM(SUM(absences)) OVER () AS Percentage
FROM hr_dataset 
GROUP BY PerformanceScore
ORDER BY PerformanceScore;

-- % of absences by position
SELECT TOP(100) PERCENT
	Position, 
	SUM(absences) * 100.0 / SUM(SUM(absences)) OVER () AS Percentage
FROM hr_dataset 
GROUP BY Position
ORDER BY Percentage desc;

-- % of absences by department and position
SELECT TOP(100) PERCENT 
	Position,
	Department,
	SUM(absences) * 100.0 / SUM(SUM(absences)) OVER () AS Percentage
FROM hr_dataset 
GROUP BY Department, Position
ORDER BY Percentage desc, Position, Department;

-- DaysLateLast30
SELECT TOP (100) PERCENT
	PerformanceScore, 
	SUM(DaysLateLast30) AS DaysLateLast30 
FROM hr_dataset 
GROUP BY PerformanceScore
ORDER BY PerformanceScore;

-- number of employees under all managers 
-- grouped by their performance scores
GO
CREATE VIEW 
	manager_info
	(PerformanceScore, ManagerID, Employees) 
AS 
	SELECT 
		TOP (100) PERCENT
		PerformanceScore, ManagerID, 
		COUNT(ManagerID) AS Employees 
	FROM 
		hr_dataset 
	GROUP BY 
		PerformanceScore, ManagerID;
GO
SELECT 
	TOP (100) PERCENT * 
FROM 
	manager_info 
ORDER BY 
	PerformanceScore, Employees;

-- salary and EmpSatisfaction
GO
CREATE VIEW emp_satisfaction AS 
	SELECT 
		PerformanceScore, 
		CAST(AVG(CONVERT(DECIMAL(10,2),Salary)) as decimal(10,2)) AvgSalary 
	FROM 
		hr_dataset 
	GROUP BY 
		PerformanceScore;
GO
SELECT * FROM emp_satisfaction;

-- avg satisfaction and performance
SELECT 
	PerformanceScore, 
	CAST(AVG(CONVERT(DECIMAL(10,2),EmpSatisfaction)) AS DECIMAL(10,2)) AvgSatisfactionRating 
FROM 
	hr_dataset 
GROUP BY 
	PerformanceScore;

-- avg satisfaction rating by position
GO
CREATE VIEW AvgSatisafactionByPosition AS
	SELECT 
		Position, 
		CAST(AVG(CONVERT(DECIMAL(10,2),EmpSatisfaction)) as DECIMAL(10,2)) AvgSatisfactionRating 
	FROM 
		hr_dataset 
	WHERE 
		Position <> 'President & CEO'
	GROUP BY 
		Position;
GO
SELECT 
	TOP(100) PERCENT  * 
FROM 
	AvgSatisafactionByPosition
ORDER BY 
	AvgSatisfactionRating DESC;

-- employees included where # of employees in position greater than 1
GO
CREATE VIEW EmployeeCountSatisfaction AS
	SELECT 
		Position, 
		CAST(AVG(CONVERT(DECIMAL(10,2),EmpSatisfaction)) AS DECIMAL(10,2)) AvgSatisfaction, 
		COUNT(Position) Employees 
	FROM 
		hr_dataset 
	GROUP BY 
		Position 
	HAVING 
		COUNT(Position) > 1;
GO
SELECT 
	TOP(100) PERCENT * 
FROM 
	EmployeeCountSatisfaction
ORDER BY 
	AvgSatisfaction DESC;

-- satisfaction by gender 
SELECT 
	Sex Gender, PerformanceScore, 
	COUNT(Sex) Employees
FROM 
	hr_dataset 
GROUP BY 
	Sex, PerformanceScore
ORDER BY 
	PerformanceScore, Sex;

GO
CREATE VIEW GenderScores AS
	SELECT 
		Sex Gender, PerformanceScore, 
		COUNT(Sex) Employees,
		CAST(AVG(CONVERT(DECIMAL(10,2),EmpSatisfaction)) as DECIMAL(10,2)) AvgEmpSatisfaction
	FROM 
		hr_dataset 
	GROUP BY 
		Sex, PerformanceScore;
GO
SELECT 
	TOP(100) PERCENT * 
FROM 
	GenderScores
ORDER BY 
	PerformanceScore, Gender;

-- gender and count of employees
-- with a satisfaction of less than 3
GO
CREATE VIEW LowEmpSatisfaction AS
	SELECT 
		Department, 
		Sex Gender, 
		PerformanceScore, 
		COUNT(Sex) Employees,
		CAST(AVG(CONVERT(DECIMAL(10,2),EmpSatisfaction)) as DECIMAL(10,2)) AvgEmpSatisfaction
	FROM 
		hr_dataset 
	GROUP BY 
		Sex, PerformanceScore, Department
	HAVING 
		AVG(EmpSatisfaction) < 3;
GO
SELECT 
	TOP(100) PERCENT *
FROM 
	LowEmpSatisfaction
ORDER BY 
	PerformanceScore, Gender;

GO
CREATE VIEW PositionLowEmpSatisfaction AS
	SELECT 
		Position, 
		Sex Gender, 
		PerformanceScore, 
		COUNT(Sex) Employees,
		CAST(AVG(CONVERT(DECIMAL(10,2),EmpSatisfaction)) AS DECIMAL(10,2)) AvgEmpSatisfaction
	FROM 
		hr_dataset 
	GROUP BY 
		Sex, PerformanceScore, Position
	HAVING 
		AVG(EmpSatisfaction) < 3;
GO
SELECT 
	TOP(100) PERCENT *
FROM 
	PositionLowEmpSatisfaction
ORDER BY 
	PerformanceScore, Gender;

-- position and empsatisfaction
-- highest number of performers by position and PerformanceScore
 -- all results
GO
CREATE VIEW PositionCountPerformance AS
WITH cte AS (
	SELECT 
		Position, PerformanceScore, 
		COUNT(*) AS Employees,
		ROW_NUMBER() OVER(partition by PerformanceScore ORDER BY COUNT(*) DESC) tops
		FROM hr_dataset 
        GROUP BY PerformanceScore,Position
		)
	SELECT Position, PerformanceScore, Employees 
    FROM cte;
GO
SELECT
	TOP(100) PERCENT *
FROM 
	PositionCountPerformance
ORDER BY 
	PerformanceScore, Employees desc;

-- employee positions with lowest performance scores
GO
CREATE VIEW LowPerformaces AS
	SELECT 
		Position, PerformanceScore, Employees 
	FROM (
		SELECT 
			Position, PerformanceScore, 
			COUNT(*) AS Employees,
			ROW_NUMBER() OVER(partition by PerformanceScore ORDER BY COUNT(*) DESC) tops
		FROM 
			hr_dataset 
		GROUP BY 
			PerformanceScore,Position) dd 
	WHERE 
		PerformanceScore = 'Needs Improvement'
		OR PerformanceScore = 'PIP';
GO
SELECT 
	TOP(100) PERCENT *
FROM 
	LowPerformaces
ORDER BY 
	PerformanceScore, Employees desc;
        
	
-- highest number of employees with specific performancescore
GO
CREATE VIEW PositionScoreCount AS
	SELECT 
		Position, PerformanceScore, Employees 
	FROM (
		SELECT Position, PerformanceScore, COUNT(*) AS Employees,
		ROW_NUMBER() OVER(partition by PerformanceScore ORDER BY COUNT(*) DESC) tops
		FROM hr_dataset 
		GROUP BY PerformanceScore,Position) position_scores 
	WHERE tops = 1;
GO
SELECT * FROM PositionScoreCount;
	
-- marital status of employees 
-- and their avg employee satisfaction ratings
GO
CREATE VIEW MaritalStatusScores AS
	SELECT
		PerformanceScore,
		IIF(MarriedID = 0,'Unmarried','Married')  AS MaritalStatus,
		CAST(AVG(CONVERT(DECIMAL(10,2),EmpSatisfaction)) AS DECIMAL(10,2)) AS EmpSatisfaction
	FROM 
		hr_dataset 
	GROUP BY 
		MarriedID, PerformanceScore;
GO
SELECT 
	TOP(100) PERCENT *
FROM 
	MaritalStatusScores
ORDER by 
	PerformanceScore, MaritalStatus;
