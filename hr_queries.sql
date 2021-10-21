USE hr_dataset;

-- total employees 
SELECT COUNT(*) AS Employees FROM hr_dataset;

-- absences and performance score
SELECT PerformanceScore, SUM(absences) AS Absences FROM hr_dataset 
GROUP BY PerformanceScore;

-- performancescores and number of absences by department
SELECT 
	PerformanceScore, Department,
	SUM(absences) AS Absences 
FROM hr_dataset 
GROUP BY PerformanceScore, Department
ORDER BY PerformanceScore, Department;

-- DaysLateLast30
SELECT 
	PerformanceScore, 
	SUM(DaysLateLast30) AS DaysLateLast30 
FROM hr_dataset 
GROUP BY PerformanceScore
ORDER BY PerformanceScore;
-- manager
SELECT 
	PerformanceScore, ManagerID, 
	COUNT(ManagerID) AS Employees 
FROM hr_dataset 
GROUP BY PerformanceScore, ManagerID
ORDER BY PerformanceScore;

-- salary and EmpSatisfaction
SELECT PerformanceScore, FORMAT(AVG(salary),'C') AS AvgSalary 
FROM hr_dataset 
GROUP BY PerformanceScore;

-- avg satisfaction and performance
SELECT 
	PerformanceScore, 
	AVG(EmpSatisfaction) AS AvgSatisfactionRating 
FROM hr_dataset 
GROUP BY PerformanceScore;

-- avg satisfaction by position
SELECT Position, AVG(EmpSatisfaction) AS AvgSatisfactionRating 
FROM hr_dataset 
WHERE Position <> 'President & CEO'
GROUP BY Position 
ORDER BY AvgSatisfactionRating DESC;

-- employees included where # of employees in position greater than 1
SELECT Position, AVG(EmpSatisfaction) AS AvgSatisfaction, 
COUNT(Position) Employees 
FROM hr_dataset 
GROUP BY Position 
HAVING COUNT(Position) > 1
ORDER BY AvgSatisfaction DESC;

-- satisfaction by gender and salary
SELECT Sex Gender, PerformanceScore, 
COUNT(Sex) Employees
FROM hr_dataset 
GROUP BY Sex, PerformanceScore
ORDER BY PerformanceScore, Sex;

SELECT Sex Gender, PerformanceScore, 
COUNT(Sex) Employees,
AVG(EmpSatisfaction) AvgEmpSatisfaction
FROM hr_dataset 
GROUP BY Sex, PerformanceScore
ORDER BY PerformanceScore, Sex;

SELECT 
Department, 
Sex Gender, 
PerformanceScore, 
COUNT(Sex) Employees,
AVG(EmpSatisfaction) AvgEmpSatisfaction
FROM hr_dataset 
GROUP BY Sex, PerformanceScore, Department
HAVING AVG(EmpSatisfaction) < 3
ORDER BY PerformanceScore, Sex;

SELECT 
Position, 
Sex Gender, 
PerformanceScore, 
COUNT(Sex) Employees,
AVG(EmpSatisfaction) AvgEmpSatisfaction
FROM hr_dataset 
GROUP BY Sex, PerformanceScore, Position
HAVING AVG(EmpSatisfaction) < 3
ORDER BY PerformanceScore, Sex;

-- position and empsatisfaction
-- highest number of performers by position and PerformanceScore
 -- all results
WITH cte AS (
	SELECT Position, PerformanceScore, COUNT(*) AS Employees,
		ROW_NUMBER() OVER(partition by PerformanceScore ORDER BY COUNT(*) DESC) tops
		FROM hr_dataset 
        GROUP BY PerformanceScore,Position
		)
	SELECT Position, PerformanceScore, Employees 
    FROM cte
	ORDER BY PerformanceScore, Employees desc;

-- lowest performers
WITH cte AS (
	SELECT Position, PerformanceScore, COUNT(*) AS Employees,
		ROW_NUMBER() OVER(partition by PerformanceScore ORDER BY COUNT(*) DESC) tops
		FROM hr_dataset 
        WHERE PerformanceScore = 'Needs Improvement' OR PerformanceScore = 'PIP'
        GROUP BY PerformanceScore,Position
		)
	SELECT Position, PerformanceScore, Employees 
    FROM cte
	ORDER BY PerformanceScore, Employees desc;
        
    -- all results of very top and very bottom
SELECT Position, PerformanceScore, Employees 
FROM (
	SELECT Position, PerformanceScore, COUNT(*) AS Employees,
	ROW_NUMBER() OVER(partition by PerformanceScore ORDER BY COUNT(*) DESC) tops
	FROM hr_dataset 
	GROUP BY PerformanceScore,Position) dd 
WHERE PerformanceScore = 'Exceeds' 
	OR PerformanceScore = 'Needs Improvement'
	OR PerformanceScore = 'PIP'
ORDER BY PerformanceScore;
        
	
    -- highest number of employees in each performancescore 
SELECT Position, PerformanceScore, Employees FROM (
SELECT Position, PerformanceScore, COUNT(*) AS Employees,
	ROW_NUMBER() OVER(partition by PerformanceScore ORDER BY COUNT(*) DESC) tops
	FROM hr_dataset 
	GROUP BY PerformanceScore,Position) dd WHERE tops = 1;
	
-- marital status
SELECT
PerformanceScore,
IIF(MarriedID = 0,'Unmarried','Married')  AS MaritalStatus,
COUNT(MarriedID) AS Employees
FROM hr_dataset 
GROUP BY MarriedID, PerformanceScore
order by PerformanceScore, Employees desc, MaritalStatus;

SELECT
PerformanceScore,
IIF(MarriedID = 0,'Unmarried','Married')  AS MaritalStatus,
AVG(EmpSatisfaction) AS EmpSatisfaction
FROM hr_dataset 
GROUP BY MarriedID, PerformanceScore
order by PerformanceScore, MaritalStatus;
