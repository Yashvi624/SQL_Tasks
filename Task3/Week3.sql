

--TASK 1

CREATE TABLE Projects (
    Task_ID INT PRIMARY KEY,
    Start_Date DATE,
    End_Date DATE
);

-- Step 2: Insert sample data
INSERT INTO Projects (Task_ID, Start_Date, End_Date) VALUES
(1, '2015-10-01', '2015-10-02'),
(2, '2015-10-02', '2015-10-03'),
(3, '2015-10-03', '2015-10-04'),
(4, '2015-10-13', '2015-10-14'),
(5, '2015-10-14', '2015-10-15'),
(6, '2015-10-28', '2015-10-29'),
(7, '2015-10-30', '2015-10-31');

SELECT * FROM Projects;

WITH OrderedTasks AS (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY Start_Date) AS rn
    FROM Projects
),
GroupedTasks AS (
    SELECT *,
           DATEADD(DAY, -rn, Start_Date) AS grp
    FROM OrderedTasks
),
ProjectsGrouped AS (
    SELECT 
        MIN(Start_Date) AS project_start,
        MAX(End_Date) AS project_end,
        DATEDIFF(DAY, MIN(Start_Date), MAX(End_Date)) AS duration
    FROM GroupedTasks
    GROUP BY grp
)
SELECT 
    project_start, 
    project_end
FROM ProjectsGrouped
ORDER BY duration ASC, project_start ASC;

--TASK 2


CREATE TABLE Students (
    ID INT PRIMARY KEY,
    Name VARCHAR(100)
);


CREATE TABLE Friends (
    ID INT PRIMARY KEY,
    Friend_ID INT
);


CREATE TABLE Packages (
    ID INT PRIMARY KEY,
    Salary FLOAT
);

INSERT INTO Students (ID, Name) VALUES
(1, 'Ashley'),
(2, 'Samantha'),
(3, 'Julia'),
(4, 'Scarlet');

INSERT INTO Friends (ID, Friend_ID) VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 1);

INSERT INTO Packages (ID, Salary) VALUES
(1, 15.20),
(2, 10.06),
(3, 11.55),
(4, 12.12);

SELECT S.Name FROM Students S JOIN Friends F ON S.ID = F.ID JOIN Packages P1 ON S.ID = P1.ID JOIN Packages P2 ON F.Friend_ID = P2.ID WHERE P2.Salary > P1.Salary ORDER BY P2.Salary;


--TASK 3

CREATE TABLE Functions (
    X INT,
    Y INT
);
INSERT INTO Functions (X, Y) VALUES
(20, 20),
(20, 20),
(20, 21),
(23, 22),
(22, 22),
(23, 21),
(21, 20);

SELECT DISTINCT
    LEAST(f1.X, f1.Y) AS X,
    GREATEST(f1.X, f1.Y) AS Y
FROM Functions f1
JOIN Functions f2
  ON f1.X = f2.Y AND f1.Y = f2.X
WHERE f1.X <= f1.Y
ORDER BY X, Y;

--TASK 4

CREATE TABLE Contests (
    contest_id INT PRIMARY KEY,
    hacker_id INT,
    name VARCHAR(100)
);
CREATE TABLE Colleges (
    college_id INT PRIMARY KEY,
    contest_id INT
);
CREATE TABLE Challenges (
    challenge_id INT PRIMARY KEY,
    college_id INT
);
CREATE TABLE View_Stats (
    challenge_id INT,
    total_views INT,
    total_unique_views INT
);
CREATE TABLE Submission_Stats (
    challenge_id INT,
    total_submissions INT,
    total_accepted_submissions INT
);

INSERT INTO Contests(contest_id, hacker_id, name) VALUES
(66406, 17973, 'Rose'),
(66556, 79153, 'Angela'),
(94828, 80275, 'Frank');

INSERT INTO Colleges (college_id, contest_id) VALUES
(11219, 66406),
(32473, 66556),
(56685, 94828);
INSERT INTO Challenges (challenge_id, college_id) VALUES
(18765, 11219),
(47127, 11219),
(60292, 72974),   
(32473, 56685);   
INSERT INTO View_Stats (challenge_id, total_views, total_unique_views) VALUES
(47127, 26, 19),
(47127, 15, 14),
(18765, 43, 10),
(18765, 72, 13),
(75516, 35, 17),
(60292, 11, 10),
(72974, 41, 15),
(75516, 75, 11);
INSERT INTO Submission_Stats (challenge_id, total_submissions, total_accepted_submissions) VALUES
(75516, 34, 12),
(47127, 27, 10),
(47127, 56, 18),
(75516, 74, 12),
(75516, 83, 8),
(72974, 68, 24),
(72974, 82, 14),
(47127, 28, 11);

SELECT 
    c.contest_id,
    c.hacker_id,
    c.name,
    SUM(ISNULL(ss.total_submissions, 0)) AS total_submissions,
    SUM(ISNULL(ss.total_accepted_submissions, 0)) AS total_accepted_submissions,
    SUM(ISNULL(vs.total_views, 0)) AS total_views,
    SUM(ISNULL(vs.total_unique_views, 0)) AS total_unique_views
FROM Contests c
JOIN Colleges co ON c.contest_id = co.contest_id
JOIN Challenges ch ON co.college_id = ch.college_id
LEFT JOIN Submission_Stats ss ON ch.challenge_id = ss.challenge_id
LEFT JOIN View_Stats vs ON ch.challenge_id = vs.challenge_id
GROUP BY c.contest_id, c.hacker_id, c.name
HAVING 
    SUM(ISNULL(ss.total_submissions, 0)) > 0 OR
    SUM(ISNULL(ss.total_accepted_submissions, 0)) > 0 OR
    SUM(ISNULL(vs.total_views, 0)) > 0 OR
    SUM(ISNULL(vs.total_unique_views, 0)) > 0
ORDER BY c.contest_id;

--TASK 5
-- Create the Hackers table
CREATE TABLE Hackers (
    hacker_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Create the Submissions table
CREATE TABLE Submissions (
    submission_id INT PRIMARY KEY,
    submission_date DATE NOT NULL,
    hacker_id INT NOT NULL,
    score INT NOT NULL,
    FOREIGN KEY (hacker_id) REFERENCES Hackers(hacker_id)
);
INSERT INTO Hackers (hacker_id, name) VALUES
(15758, 'Rose'),
(20703, 'Angela'),
(36396, 'Frank'),
(38289, 'Patrick'),
(44065, 'Lisa'),
(53473, 'Kimberly'),
(62529, 'Bonnie'),
(79722, 'Michael');

INSERT INTO Submissions (submission_date, submission_id, hacker_id, score) VALUES
('2016-03-01', 8494, 20703, 0),
('2016-03-01', 22403, 53473, 15),
('2016-03-01', 23965, 79722, 60),
('2016-03-01', 30173, 36396, 70),
('2016-03-02', 34928, 20703, 0),
('2016-03-02', 38740, 15758, 60),
('2016-03-02', 42769, 79722, 25),
('2016-03-02', 44364, 79722, 60),
('2016-03-03', 45440, 20703, 0),
('2016-03-03', 49050, 36396, 70),
('2016-03-03', 50273, 79722, 5),
('2016-03-04', 50344, 20703, 0),
('2016-03-04', 51360, 44065, 90),
('2016-03-04', 54404, 53473, 65),
('2016-03-04', 61533, 79722, 45),
('2016-03-05', 72852, 20703, 0),
('2016-03-05', 74546, 38289, 0),
('2016-03-05', 76487, 62529, 0),
('2016-03-05', 82439, 36396, 10),
('2016-03-05', 90006, 36396, 40),
('2016-03-06', 90404, 20703, 0);

WITH daily_hacker_subs AS (
    SELECT
        submission_date,
        hacker_id,
        COUNT(*) AS submission_count
    FROM Submissions
    GROUP BY submission_date, hacker_id
),
max_subs_per_day AS (
    SELECT
        submission_date,
        MAX(submission_count) AS max_subs
    FROM daily_hacker_subs
    GROUP BY submission_date
),
top_hackers AS (
    SELECT
        d.submission_date,
        d.hacker_id,
        d.submission_count
    FROM daily_hacker_subs d
    JOIN max_subs_per_day m
        ON d.submission_date = m.submission_date
       AND d.submission_count = m.max_subs
),
ranked_top_hackers AS (
    SELECT
        submission_date,
        hacker_id,
        ROW_NUMBER() OVER (PARTITION BY submission_date ORDER BY hacker_id) AS rk
    FROM top_hackers
),
final_top_hackers AS (
    SELECT
        r.submission_date,
        r.hacker_id,
        h.name
    FROM ranked_top_hackers r
    JOIN Hackers h ON r.hacker_id = h.hacker_id
    WHERE r.rk = 1
),
unique_hacker_counts AS (
    SELECT
        submission_date,
        COUNT(DISTINCT hacker_id) AS unique_hackers
    FROM Submissions
    GROUP BY submission_date
)

SELECT
    u.submission_date,
    u.unique_hackers,
    f.hacker_id,
    f.name
FROM unique_hacker_counts u
JOIN final_top_hackers f
    ON u.submission_date = f.submission_date
ORDER BY u.submission_date;

--TASK 6
CREATE TABLE STATION (
    ID INT PRIMARY KEY,
    CITY VARCHAR(21),
    STATE VARCHAR(2),
    LAT_N DECIMAL(10, 4),   
    LONG_W DECIMAL(10, 4)   
);
INSERT INTO STATION (ID, CITY, STATE, LAT_N, LONG_W) VALUES
(1, 'San Francisco', 'CA', 37.7749, 122.4194),
(2, 'New York', 'NY', 40.7128, 74.0060),
(3, 'Chicago', 'IL', 41.8781, 87.6298),
(4, 'Seattle', 'WA', 47.6062, 122.3321),
(5, 'Houston', 'TX', 29.7604, 95.3698),
(6, 'Denver', 'CO', 39.7392, 104.9903),
(7, 'Miami', 'FL', 25.7617, 80.1918),
(8, 'Phoenix', 'AZ', 33.4484, 112.0740);

SELECT
  ROUND(
    ABS(MIN(LAT_N) - MAX(LAT_N)) +
    ABS(MIN(LONG_W) - MAX(LONG_W)),
    4
  ) AS manhattan_distance
FROM STATION;

WITH Numbers AS (
    SELECT 2 AS num
    UNION ALL
    SELECT num + 1
    FROM Numbers
    WHERE num + 1 <= 1000
),
Primes AS (
    SELECT num
    FROM Numbers n
    WHERE NOT EXISTS (
        SELECT 1
        FROM Numbers d
        WHERE d.num < n.num AND d.num > 1 AND n.num % d.num = 0
    )
)
SELECT STRING_AGG(CAST(num AS VARCHAR), '&') AS primes
FROM Primes
OPTION (MAXRECURSION 1000);

--TASK 8
CREATE TABLE OCCUPATIONS (
    Name VARCHAR(100),
    Occupation VARCHAR(20) CHECK (Occupation IN ('Doctor', 'Professor', 'Singer', 'Actor'))
);

INSERT INTO OCCUPATIONS (Name, Occupation) VALUES
('Samantha', 'Doctor'),
('Julia', 'Actor'),
('Maria', 'Actor'),
('Meera', 'Singer'),
('Ashely', 'Professor'),
('Ketty', 'Professor'),
('Christeen', 'Professor'),
('Jane', 'Actor'),
('Jenny', 'Doctor'),
('Priya', 'Singer');

SELECT
    MAX(CASE WHEN Occupation = 'Doctor' THEN Name END) AS Doctor,
    MAX(CASE WHEN Occupation = 'Professor' THEN Name END) AS Professor,
    MAX(CASE WHEN Occupation = 'Singer' THEN Name END) AS Singer,
    MAX(CASE WHEN Occupation = 'Actor' THEN Name END) AS Actor
FROM (
    SELECT
        Name,
        Occupation,
        ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name) AS rn
    FROM OCCUPATIONS
) AS ranked
GROUP BY rn
ORDER BY rn;

--TASK 9
CREATE TABLE BST (
    N INT PRIMARY KEY,  
    P INT               
);

INSERT INTO BST (N, P) VALUES
(1, 3),
(2, 2),
(6, 8),
(9, 2),
(8, 8),
(5, NULL),   
(3, 5);

SELECT
    N,
    CASE
        WHEN P IS NULL THEN 'Root'
        WHEN N NOT IN (SELECT DISTINCT P FROM BST WHERE P IS NOT NULL) THEN 'Leaf'
        ELSE 'Inner'
    END AS NodeType
FROM BST
ORDER BY N;

--TASK 10
CREATE TABLE Company (
    company_code VARCHAR(50) PRIMARY KEY,
    founder VARCHAR(100)
);
CREATE TABLE Lead_Manager (
    lead_manager_code VARCHAR(50) PRIMARY KEY,
    company_code VARCHAR(50)
);
CREATE TABLE Senior_Manager (
    senior_manager_code VARCHAR(50) PRIMARY KEY,
    lead_manager_code VARCHAR(50),
    company_code VARCHAR(50)
);
CREATE TABLE Manager (
    manager_code VARCHAR(50) PRIMARY KEY,
    senior_manager_code VARCHAR(50),
    lead_manager_code VARCHAR(50),
    company_code VARCHAR(50)
);
CREATE TABLE Employee (
    employee_code VARCHAR(50) PRIMARY KEY,
    manager_code VARCHAR(50),
    senior_manager_code VARCHAR(50),
    lead_manager_code VARCHAR(50),
    company_code VARCHAR(50)
);

INSERT INTO Company (company_code, founder) VALUES
('C1', 'Monika'),
('C2', 'Samantha');
INSERT INTO Lead_Manager (lead_manager_code, company_code) VALUES
('LM1', 'C1'),
('LM2', 'C2');
INSERT INTO Senior_Manager (senior_manager_code, lead_manager_code, company_code) VALUES
('SM1', 'LM1', 'C1'),
('SM2', 'LM1', 'C1'),
('SM3', 'LM2', 'C2');
INSERT INTO Manager (manager_code, senior_manager_code, lead_manager_code, company_code) VALUES
('M1', 'SM1', 'LM1', 'C1'),
('M2', 'SM3', 'LM2', 'C2'),
('M3', 'SM3', 'LM2', 'C2');
INSERT INTO Employee (employee_code, manager_code, senior_manager_code, lead_manager_code, company_code) VALUES
('E1', 'M1', 'SM1', 'LM1', 'C1'),
('E2', 'M1', 'SM1', 'LM1', 'C1'),
('E3', 'M2', 'SM3', 'LM2', 'C2'),
('E4', 'M3', 'SM3', 'LM2', 'C2');

SELECT
  c.company_code,
  c.founder,
  (SELECT COUNT(DISTINCT lead_manager_code) FROM Lead_Manager WHERE company_code = c.company_code) AS total_lead_managers,
  (SELECT COUNT(DISTINCT senior_manager_code) FROM Senior_Manager WHERE company_code = c.company_code) AS total_senior_managers,
  (SELECT COUNT(DISTINCT manager_code) FROM Manager WHERE company_code = c.company_code) AS total_managers,
  (SELECT COUNT(DISTINCT employee_code) FROM Employee WHERE company_code = c.company_code) AS total_employees
FROM Company c
ORDER BY c.company_code;

--TASK11
CREATE TABLE Students1 (
    ID INT PRIMARY KEY,
    Name VARCHAR(50)
);

CREATE TABLE Friends1 (
    ID INT PRIMARY KEY,
    Friend_ID INT
);

CREATE TABLE Packages1 (
    ID INT PRIMARY KEY,
    Salary FLOAT
);
-- Students
INSERT INTO Students1 (ID, Name) VALUES
(1, 'Ashley'),
(10, 'Samantha'),
(3, 'Julia'),
(4, 'Scarlet'),
(2, 'Scarlet'); 
-- Friends
INSERT INTO Friends1 (ID, Friend_ID) VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 1);

-- Packages
INSERT INTO Packages1 (ID, Salary) VALUES
(1, 15.20),
(3, 11.55),
(4, 12.12),
(2, 10.06);
INSERT INTO Packages (ID, Salary) VALUES (10, 10.06);
SELECT s.Name
FROM Students1 s
JOIN Friends1 f ON s.ID = f.ID
JOIN Packages1 p_student ON s.ID = p_student.ID
JOIN Packages1 p_friend ON f.Friend_ID = p_friend.ID
WHERE p_friend.Salary > p_student.Salary
ORDER BY p_friend.Salary;

--TASK 12
CREATE TABLE Jobs (
    job_family VARCHAR(50),
    location VARCHAR(20),
    cost DECIMAL(10, 2)
);
INSERT INTO Jobs (job_family, location, cost) VALUES
('Engineering', 'India', 50000.00),
('Engineering', 'International', 75000.00),
('Marketing', 'India', 30000.00),
('Marketing', 'International', 45000.00),
('Sales', 'India', 20000.00),
('Sales', 'International', 25000.00),
('HR', 'India', 10000.00),
('HR', 'International', 15000.00);

SELECT 
    job_family,
    ROUND(100.0 * SUM(CASE WHEN location = 'India' THEN cost ELSE 0 END) / SUM(cost), 2) AS india_percentage,
    ROUND(100.0 * SUM(CASE WHEN location = 'International' THEN cost ELSE 0 END) / SUM(cost), 2) AS international_percentage
FROM Jobs
GROUP BY job_family;

--TASK 13
CREATE TABLE BU_Data (
    bu VARCHAR(10),
    month VARCHAR(7), 
    cost DECIMAL(10,2),
    revenue DECIMAL(10,2)
);
INSERT INTO BU_Data (bu, month, cost, revenue) VALUES
('BU1', '2023-01', 20000.00, 50000.00),
('BU1', '2023-02', 22000.00, 52000.00),
('BU1', '2023-03', 18000.00, 49000.00),
('BU2', '2023-01', 25000.00, 60000.00),
('BU2', '2023-02', 27000.00, 62000.00),
('BU2', '2023-03', 30000.00, 70000.00),
('BU3', '2023-01', 15000.00, 40000.00),
('BU3', '2023-02', 18000.00, 42000.00);

SELECT
    bu,
    month,
    cost,
    revenue,
    ROUND(cost / revenue * 100, 2) AS cost_to_revenue_percentage
FROM
    BU_Data
ORDER BY
    bu,
    month;



--TASK14
CREATE TABLE Employees (
    employee_id INT,
    sub_band VARCHAR(10)
);
INSERT INTO Employees (employee_id, sub_band) VALUES
(1, 'SB1'),
(2, 'SB1'),
(3, 'SB2'),
(4, 'SB2'),
(5, 'SB2'),
(6, 'SB3'),
(7, 'SB3'),
(8, 'SB3'),
(9, 'SB3'),
(10, 'SB4');

SELECT
    e.sub_band,
    COUNT(e.employee_id) AS headcount,
    ROUND(COUNT(e.employee_id) * 100.0 / total.total_count, 2) AS percentage
FROM
    Employees e,
    (SELECT COUNT(*) AS total_count FROM Employees) AS total
GROUP BY
    e.sub_band, total.total_count
ORDER BY
    e.sub_band;

--TASK15
CREATE TABLE EmployeesSalary (
    emp_id INT,
    emp_name VARCHAR(100),
    salary INT
);

INSERT INTO EmployeesSalary VALUES
(1, 'Alice', 50000),
(2, 'Bob', 70000),
(3, 'Charlie', 60000),
(4, 'David', 80000),
(5, 'Eve', 55000),
(6, 'Frank', 75000),
(7, 'Grace', 72000);

WITH RankedSalaries AS (
    SELECT emp_id, emp_name, salary,
           RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM EmployeesSalary
)
SELECT emp_id, emp_name, salary
FROM RankedSalaries
WHERE rnk <= 5;

--TASK 16
CREATE TABLE SwapTest (
    id INT,
    col1 INT,
    col2 INT
);

INSERT INTO SwapTest VALUES (1, 10, 20);

UPDATE SwapTest
SET 
    col1 = new_col1,
    col2 = new_col2
FROM (
    SELECT 
        id,
        col1 + col2 AS new_col1,
        col1 AS temp_col1,
        col2 AS temp_col2,
        (col1 + col2 - col2) AS new_col2
    FROM SwapTest
) AS t
WHERE SwapTest.id = t.id;

SELECT * FROM SwapTest;
--TASK 17

CREATE LOGIN TestUserLogin WITH PASSWORD = 'StrongPassword123!';

CREATE USER TestUser FOR LOGIN TestUserLogin;

EXEC sp_addrolemember 'db_owner', 'TestUser';

--TASK 18
CREATE TABLE BU_Cost (
    bu VARCHAR(10),
    month VARCHAR(7),
    emp_id INT,
    cost DECIMAL(10,2),
    weight DECIMAL(5,2)
);

INSERT INTO BU_Cost VALUES
('BU1', '2023-01', 1, 1000.00, 0.2),
('BU1', '2023-01', 2, 2000.00, 0.3),
('BU1', '2023-01', 3, 1500.00, 0.5),
('BU2', '2023-01', 4, 2500.00, 0.4),
('BU2', '2023-01', 5, 3000.00, 0.6);

SELECT
    bu,
    month,
    ROUND(SUM(cost * weight) / SUM(weight), 2) AS weighted_avg_cost
FROM BU_Cost
GROUP BY bu, month
ORDER BY bu, month;

--TASK 19
CREATE TABLE EMPLOYEES1 (
    ID INT,
    NAME VARCHAR(50),
    SALARY INT
);
INSERT INTO EMPLOYEES1 (ID, NAME, SALARY) VALUES
(1, 'Alice', 9000),
(2, 'Bob', 1500),
(3, 'Charlie', 3000),
(4, 'David', 4500);

SELECT 
  CEILING(
    AVG(CAST(SALARY AS FLOAT)) 
    - 
    AVG(CAST(REPLACE(CAST(SALARY AS VARCHAR), '0', '') AS FLOAT))
  ) AS error_amount
FROM EMPLOYEES1;

--TASK 20
CREATE TABLE SourceTable (
    ID INT,
    Name VARCHAR(50),
    Age INT
);

CREATE TABLE TargetTable (
    ID INT,
    Name VARCHAR(50),
    Age INT
);

INSERT INTO SourceTable VALUES (1, 'Alice', 30), (2, 'Bob', 25), (3, 'Charlie', 22);

INSERT INTO TargetTable VALUES (1, 'Alice', 30);

INSERT INTO TargetTable (ID, Name, Age)
SELECT s.ID, s.Name, s.Age
FROM SourceTable s
WHERE NOT EXISTS (
    SELECT 1 
    FROM TargetTable t
    WHERE t.ID = s.ID
);

SELECT * FROM TargetTable;





 














