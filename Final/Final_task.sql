CREATE DATABASE EmployeesInfo;

USE EmployeesInfo;

CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL
);

CREATE TABLE Employees(
   EmployeeID INT PRIMARY KEY,
   Name VARCHAR(50),
   DepartmentID INT,
   FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID) ,
   Salary DECIMAL(10,2) NOT NULL CHECK (Salary>=0)
);
INSERT INTO Departments (DepartmentID, DepartmentName) VALUES
(1, 'Marketing'),
(2, 'Research'),
(3, 'Development');
SELECT * FROM Departments;

INSERT INTO Employees (EmployeeID, Name, DepartmentID, Salary) VALUES
(1, 'John Doe', 1, 60000.00),
(2, 'Jane Smith', 1, 70000.00),
(3, 'Alice Johnson', 1, 65000.00),
(4, 'Bob Brown', 1, 75000.00),
(5, 'Charlie Wilson', 1, 80000.00),
(6, 'Eva Lee', 2, 70000.00),
(7, 'Michael Clark', 2, 75000.00),
(8, 'Sarah Davis', 2, 80000.00),
(9, 'Ryan Harris', 2, 85000.00),
(10, 'Emily White', 2, 90000.00),
(11, 'David Martinez', 3, 95000.00),
(12, 'Jessica Taylor', 3, 100000.00),
(13, 'William Rodriguez', 3, 105000.00);
SELECT * FROM Employees;

/* SQL query to find the average salary of employees in each department, along with the
department name and the number of employees in each department. However, only include
departments where the average salary is higher than the overall average salary across all departments.*/

SELECT TOP 1 DepartmentName , AVG(Salary) AS AverageSalary , Count(EmployeeID) AS NumberOfEmployees 
FROM Employees, Departments WHERE Employees.DepartmentID = Departments.DepartmentID  
GROUP BY DepartmentName 
ORDER BY AverageSalary DESC;