USE UserDB;

CREATE TABLE dim_customer (
customer_id INT PRIMARY KEY,
name NVARCHAR(100),
city NVARCHAR(100),
previous_city NVARCHAR(100), 
start_date DATE, 
end_date DATE, 
is_current BIT 
);

CREATE TABLE stg_customer (
customer_id INT,
name NVARCHAR(100),
city NVARCHAR(100)
);
INSERT INTO dim_customer (customer_id, name, city)
VALUES
(1, 'Alice', 'Mumbai'),
(2, 'Bob', 'Delhi'),
(3, 'Charlie', 'Bangalore');

INSERT INTO stg_customer (customer_id, name, city)
VALUES
(1, 'Alice', 'Pune'), 
(2, 'Bob', 'Delhi'), 
(4, 'David', 'Hyderabad'); 

select * from dim_customer;
select * from stg_customer;

--TYPE 0 SCD
GO
CREATE PROCEDURE sp_scd_type_0
AS
BEGIN
PRINT 'No changes are allowed in SCD Type 0';
END

EXEC sp_scd_type_0;

--TYPE 1 SCD
GO
CREATE PROCEDURE sp_scd_type_1
AS
BEGIN
UPDATE dim_customer
SET
name=s.name,
city=s.city
FROM stg_customer s
WHERE dim_customer.customer_id=s.customer_id;
-- Insert new records
INSERT INTO dim_customer (customer_id, name, city)
SELECT s.customer_id, s.name, s.city
FROM stg_customer s
LEFT JOIN dim_customer d ON s.customer_id = d.customer_id
WHERE d.customer_id IS NULL;
END
EXEC sp_scd_type_1;



DROP TABLE IF EXISTS dim_customer;

CREATE TABLE dim_customer (
dim_id INT IDENTITY(1,1) PRIMARY KEY
customer_id INT, 
name NVARCHAR(100),
city NVARCHAR(100),
start_date DATE,
end_date DATE,
is_current BIT
);
INSERT INTO dim_customer (customer_id, name, city, start_date, end_date, is_current)
VALUES
(1, 'Alice', 'Mumbai', '2024-01-01', NULL, 1),
(2, 'Bob', 'Delhi', '2024-01-01', NULL, 1);

TRUNCATE TABLE stg_customer;

INSERT INTO stg_customer (customer_id, name, city)
VALUES
(1, 'Alice', 'Pune'), 
(2, 'Bob', 'Delhi'), 
(3, 'Charlie', 'Bangalore'); 
-- TYPE 2 SCD
GO
CREATE PROCEDURE sp_scd_type_2
AS
BEGIN
DECLARE @today DATE = GETDATE();
UPDATE dim_customer
SET end_date = @today,
    is_current = 0
FROM dim_customer d
JOIN stg_customer s ON d.customer_id = s.customer_id
WHERE d.is_current = 1 AND (d.name <> s.name OR d.city <> s.city);

INSERT INTO dim_customer (customer_id, name, city, start_date, end_date, is_current)
SELECT s.customer_id, s.name, s.city, @today, NULL, 1
FROM stg_customer s
LEFT JOIN dim_customer d ON s.customer_id = d.customer_id AND d.is_current = 1
WHERE d.customer_id IS NULL OR s.name <> d.name OR s.city <> d.city;
END 
GO
EXEC sp_scd_type_2;

DROP TABLE IF EXISTS dim_customer;

CREATE TABLE dim_customer (
customer_id INT PRIMARY KEY,
name NVARCHAR(100),
city NVARCHAR(100), 
previous_city NVARCHAR(100) 
);

DROP TABLE IF EXISTS stg_customer;

CREATE TABLE stg_customer (
customer_id INT,
name NVARCHAR(100),
city NVARCHAR(100)
);
INSERT INTO dim_customer (customer_id, name, city, previous_city)
VALUES
(1, 'Alice', 'Mumbai', NULL),
(2, 'Bob', 'Delhi', NULL);

INSERT INTO stg_customer (customer_id, name, city)
VALUES
(1, 'Alice', 'Pune'), 
(2, 'Bob', 'Delhi'), 
(3, 'Charlie', 'Kolkata'); 

--TYPE 3 SCD
GO
CREATE OR ALTER PROCEDURE sp_scd_type_3
AS
BEGIN
UPDATE dim_customer
SET
previous_city = dim_customer.city,
city = s.city
FROM stg_customer s
WHERE dim_customer.customer_id = s.customer_id
AND s.city <> dim_customer.city;

-- Insert new customers
INSERT INTO dim_customer (customer_id, name, city, previous_city)
SELECT s.customer_id, s.name, s.city, NULL
FROM stg_customer s
LEFT JOIN dim_customer d ON s.customer_id = d.customer_id
WHERE d.customer_id IS NULL;
END

EXEC sp_scd_type_3;


--TYPE 4 SCD
TRUNCATE TABLE stg_customer;
INSERT INTO stg_customer (customer_id, name, city)
VALUES
(1, 'Alice', 'Baroda'),
(2, 'Bob', 'Delhi'), 
(4, 'David', 'Ahmedabad'); 

CREATE TABLE hist_customer (
customer_id INT,
name NVARCHAR(100),
city NVARCHAR(100),
change_date DATE
);

GO
CREATE PROCEDURE sp_scd_type_4
AS
BEGIN
DECLARE @today DATE = GETDATE();
-- Archive changed records
INSERT INTO hist_customer (customer_id, name, city, change_date)
SELECT d.customer_id, d.name, d.city, @today
FROM dim_customer d++
JOIN stg_customer s ON d.customer_id = s.customer_id
WHERE d.city <> s.city;

UPDATE dim_customer
SET name = s.name,
    city = s.city
FROM stg_customer s
WHERE dim_customer.customer_id = s.customer_id;

INSERT INTO dim_customer (customer_id, name, city)
SELECT s.customer_id, s.name, s.city
FROM stg_customer s
LEFT JOIN dim_customer d ON s.customer_id = d.customer_id
WHERE d.customer_id IS NULL;
END
GO
EXEC sp_scd_type_4

select * from dim_customer;
select * from stg_customer;
select * from hist_customer;


-- TYPE 6 SCD
DROP TABLE IF EXISTS dim_customer;
CREATE TABLE dim_customer (
dim_id INT IDENTITY(1,1) PRIMARY KEY,
customer_id INT,
name NVARCHAR(100),
city NVARCHAR(100),
previous_city NVARCHAR(100), 
start_date DATE,
end_date DATE,
is_current BIT
);
DROP TABLE IF EXISTS stg_customer;

CREATE TABLE stg_customer (
customer_id INT,
name NVARCHAR(100),
city NVARCHAR(100)
);
INSERT INTO dim_customer (customer_id, name, city, previous_city, start_date, end_date, is_current)
VALUES
(1, 'Alice', 'Mumbai', NULL, '2024-01-01', NULL, 1),
(2, 'Bob', 'Delhi', NULL, '2024-01-01', NULL, 1);

INSERT INTO stg_customer (customer_id, name, city)
VALUES
(1, 'Alice', 'Pune'),
(2, 'Bob', 'Delhi'), 
(3, 'Charlie', 'Kolkata'); 
GO
CREATE OR ALTER PROCEDURE sp_scd_type_6
AS
BEGIN
DECLARE @today DATE = GETDATE();

UPDATE dim_customer
SET end_date = @today,
    is_current = 0
FROM dim_customer d
JOIN stg_customer s ON d.customer_id = s.customer_id
WHERE d.is_current = 1 AND (d.name <> s.name OR d.city <> s.city);

INSERT INTO dim_customer (customer_id, name, city, previous_city, start_date, end_date, is_current)
SELECT 
    s.customer_id,
    s.name,
    s.city,
    d.city,       
    @today,
    NULL,
    1
FROM stg_customer s
JOIN dim_customer d ON s.customer_id = d.customer_id
WHERE d.is_current = 1 AND (d.name <> s.name OR d.city <> s.city);

INSERT INTO dim_customer (customer_id, name, city, previous_city, start_date, end_date, is_current)
SELECT 
    s.customer_id,
    s.name,
    s.city,
    NULL,
    @today,
    NULL,
    1
FROM stg_customer s
LEFT JOIN dim_customer d ON s.customer_id = d.customer_id
WHERE d.customer_id IS NULL;
END;
GO
EXEC sp_scd_type_6;

SELECT * FROM dim_customer;
SELECT * FROM stg_customer;