USE hr_dataset;

-- delete record with missing empid and name
DELETE 
FROM hr_dataset
WHERE EmpID IS NULL AND Employee_Name IS NULL;

-- Clean up termination reason text
UPDATE hr_dataset
SET TermReason = 
	CASE TermReason
		WHEN 'N/A-StillEmployed' THEN 'Still Employed'
        WHEN 'relocation out of area' THEN 'Relocated'
        WHEN 'retiring' THEN 'Retired'
        WHEN 'return to school' THEN 'Returned To School'
        WHEN 'Another position' THEN 'Changed Positions'
        WHEN 'career change' THEN 'Changed Careers'
        WHEN 'maternity leave - did not return' THEN 'Failed to Return After Maternity Leave'
        WHEN 'Fatal attraction' THEN 'Misconduct'
        WHEN 'Learned that he is a gangster' THEN 'Involved In Gang Activity'
		WHEN 'Attendance' THEN 'Poor Attendance'
        WHEN 'Performance' THEN 'Poor Performance'
        WHEN 'More money' THEN 'Salary Increase'
	END;

-- update employee records with missing manager id values
UPDATE tableA
SET 
	tableA.ManagerName = tableB.ManagerName
FROM 
	hr_dataset AS tableA
JOIN 
	hr_dataset AS tableB
ON tableA.ManagerID=tableB.ManagerID
	AND tableA.EmpId<>tableB.EmpId
WHERE tableA.ManagerName IS NULL AND tableB.ManagerName IS NOT NULL;

-- update employee records with missing manager name values
UPDATE tableA
SET 
	tableA.ManagerID = tableB.ManagerID
FROM 
	hr_dataset AS tableA
JOIN 
	hr_dataset AS tableB
ON tableA.ManagerName=tableB.ManagerName
	AND tableA.EmpId<>tableB.EmpId
WHERE tableA.ManagerID IS NULL AND tableB.ManagerID IS NOT NULL;

-- update all zip codes to 5 digit format
UPDATE hr_dataset 
SET 
    Zip = CASE
        WHEN LEN(Zip) < 5 THEN CONCAT(0, Zip)
        ELSE Zip
    END;

-- remove duplicate records with same employee name; keep oldest
DELETE 
	tableA
FROM 
	hr_dataset tableA
JOIN 
	hr_dataset tableB
ON 
	tableA.Employee_Name=tableB.Employee_Name
	AND tableA.EmpId > tableB.EmpId;
	




