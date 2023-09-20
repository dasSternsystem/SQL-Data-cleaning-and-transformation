--Making database by name Cleaning_Project
if not exists (
  select 
    name 
  from 
    sys.databases 
  where 
    name = 'Cleaning_Project'
) Begin Create database Cleaning_Project END --Exploring data
use Cleaning_Project 
select 
  TOP 10 * 
from 
  Cleaning --Making store procedure 
  CREATE PROCEDURE TOP_10 AS BEGIN 
select 
  TOP 10 * 
from 
  Cleaning END;
top_10 -- Changing names of columns
EXEC sp_rename 'Cleaning.[Id?empl]', 
'id_emp', 
'COLUMN';
ALTER TABLE 
  Cleaning ALTER COLUMN id_emp varchar(50) NULL EXEC sp_rename 'Cleaning."Name"', 
  'name', 
  'COLUMN';
ALTER TABLE 
  Cleaning ALTER COLUMN last_name varchar(50) NULL EXEC sp_rename 'Cleaning."Lastname"', 
  'last_name', 
  'COLUMN';
ALTER TABLE 
  Cleaning ALTER COLUMN last_name varchar(50) NULL EXEC sp_rename 'Cleaning."star_date"', 
  'start_date', 
  'COLUMN';
ALTER TABLE 
  Cleaning ALTER COLUMN start_date date NULL;
EXEC sp_rename 'Cleaning."Work_mode"', 
'work_mode', 
'COLUMN' 
ALTER TABLE 
  Cleaning ALTER COLUMN work_mode bit NULL -- Removing duplicates
Select 
  Id_emp, 
  count (*) as number_of_duplicates 
from 
  Cleaning 
group by 
  Id_emp 
having 
  count(*)> 1 
select 
  count(*) as number_of_duplicates 
from 
  (
    select 
      Id_emp, 
      count (*) as number_of_duplicates 
    from 
      Cleaning 
    group by 
      Id_emp 
    having 
      count(*)> 1
  ) as subquery EXEC sp_rename 'Cleaning', 
  'Cl_duplicates';
SELECT 
  DISTINCT * INTO #temp_cleaning
FROM 
  Cl_duplicates -- Check the number of records
SELECT 
  COUNT(*) AS original 
FROM 
  Cl_duplicates;
SELECT 
  COUNT(*) AS temporal 
FROM 
  #temp_cleaning;
  -- Check for duplicates again
select 
  count(*) as number_of_duplicates 
from 
  (
    select 
      Id_emp, 
      count (*) as number_of_duplicates 
    from 
      Cleaning 
    group by 
      Id_emp 
    having 
      count(*)> 1
  ) as subquery -- Convert the temporary table to permanent
SELECT 
  * INTO Cleaning 
FROM 
  #temp_cleaning;
  -- Drop the table that contains duplicates
DROP 
  TABLE Cl_duplicates;
--Describe table
EXEC sp_columns 'Cleaning';
-- Find names with extra spaces
SELECT 
  Name, 
  LTRIM(
    RTRIM(Name)
  ) AS Name 
FROM 
  Cleaning 
WHERE 
  LEN(Name) - LEN(
    LTRIM(
      RTRIM(Name)
    )
  ) > 0;
-- Update names with extra spaces
UPDATE 
  Cleaning 
SET 
  Name = LTRIM(
    RTRIM(Name)
  ) 
WHERE 
  LEN(Name) - LEN(
    LTRIM(
      RTRIM(Name)
    )
  ) > 0;
-- Find last names with extra spaces
SELECT 
  last_name, 
  LTRIM(
    RTRIM(last_name)
  ) AS Last_name 
FROM 
  Cleaning 
WHERE 
  LEN(last_name) - LEN(
    LTRIM(
      RTRIM(last_name)
    )
  ) > 0;
-- Update last names with extra spaces
UPDATE 
  Cleaning 
SET 
  last_name = LTRIM(
    RTRIM(last_name)
  ) 
WHERE 
  LEN(last_name) - LEN(
    LTRIM(
      RTRIM(last_name)
    )
  ) > 0;
-- Identify extra spaces between words
-- Add extra spaces intentionally
UPDATE 
  Cleaning 
SET 
  area = REPLACE(area, ' ', '       ');
-- Explore if there are two or more spaces between words
SELECT 
  area 
FROM 
  Cleaning 
WHERE 
  area LIKE '%  %';
-- This pattern matches two or more consecutive spaces
-- Replace multiple spaces with a single space
UPDATE 
  Cleaning 
SET 
  area = REPLACE(area, '  ', ' ');
-- Explore if there are still extra spaces
SELECT 
  area 
FROM 
  Cleaning 
WHERE 
  area LIKE '%  %';
top_10 -- Adjusting gender
-- Test
SELECT 
  gender, 
  CASE WHEN gender = 'M' THEN 'Male' WHEN gender = 'F' THEN 'Female' ELSE 'Other' END AS AdjustedGender 
FROM 
  Cleaning;
-- Update the table
UPDATE 
  Cleaning 
SET 
  gender = CASE WHEN gender = 'M' THEN 'Male' WHEN Gender = 'F' THEN 'Female' ELSE 'Other' END;
top_10 -- Change data type and replace data
-- Alter the data type of the work_mode column to TEXT
ALTER TABLE 
  Cleaning ALTER COLUMN work_mode VARCHAR(MAX);
-- Modify the data type to VARCHAR(MAX)
-- Select the work_mode column and use CASE to update the values
SELECT 
  work_mode, 
  CASE WHEN work_mode = '1' THEN 'On-site' WHEN work_mode = '0' THEN 'Remote' ELSE 'Other' END AS example 
FROM 
  Cleaning;
-- Update the original table with the adjusted values
UPDATE 
  Cleaning 
SET 
  work_mode = CASE WHEN work_mode = '1' THEN 'On-site' WHEN work_mode = '0' THEN 'Remote' ELSE 'Other' END;
top_10 -- Adjust number format
-- Replace $ with an empty string and remove the thousands separator
UPDATE 
  Cleaning 
SET 
  salary = CAST(
    REPLACE(
      REPLACE(salary, '$', ''), 
      ',', 
      ''
    ) AS DECIMAL(15, 2)
  );
-- Explanation:
-- REPLACE(salary, '$', ''): Removes the dollar sign ('$') from the 'salary' column and replaces it with an empty string.
-- REPLACE(..., ',', ''): Removes commas (',') from the 'salary' column and replaces them with an empty string.
-- CAST(... AS DECIMAL(15, 2)): Converts the resulting value into a decimal number with a total precision of 15 digits and 2 decimal places.
top_10 -- Working with Dates --
-- Alter the data type of text columns to dates
-- Use ALTER TABLE to modify the data type of columns
-- Birth_day
-- Check how the dates are formatted
-- Use SELECT to examine the date formats
SELECT 
  birth_date 
FROM 
  Cleaning;
-- Update 'birth_date' to DATE type where not NULL.
-- "Rehearsal" - Format the date
-- Use CASE to evaluate and replace values based on conditions
-- Format dates to YYYY-MM-DD
UPDATE 
  Cleaning 
SET 
  birth_date = CAST(birth_date AS DATE) 
WHERE 
  birth_date IS NOT NULL;

UPDATE 
  Cleaning 
SET 
  birth_date = CASE WHEN birth_date LIKE '%/%' THEN CONVERT(DATE, birth_date, 101) -- MM/DD/YYYY format
  WHEN birth_date LIKE '%-%' THEN CONVERT(DATE, birth_date, 110) -- MM-DD-YYYY format
  ELSE NULL END;
-- # Start_date
-- Identify the date formats
SELECT 
  start_date 
FROM 
  Cleaning;
-- In SQL, the date format is YYYY-MM-DD (Year, Month, Day)
-- ----- "Test" - Format the date
SELECT 
  start_date, 
  CASE WHEN CHARINDEX('/', start_date) > 0 THEN CONVERT(DATE, start_date, 101) -- MM/DD/YYYY
  WHEN CHARINDEX('-', start_date) > 0 THEN CONVERT(DATE, start_date, 110) -- MM-DD-YYYY
  ELSE NULL END AS new_start_date 
FROM 
  Cleaning;
-- ----- Update the table
UPDATE 
  Cleaning 
SET 
  start_date = CASE WHEN CHARINDEX('/', start_date) > 0 THEN CONVERT(DATE, start_date, 101) -- MM/DD/YYYY
  WHEN CHARINDEX('-', start_date) > 0 THEN CONVERT(DATE, start_date, 110) -- MM-DD-YYYY
  ELSE NULL END;
-- Change the data type of the column
ALTER TABLE 
  Cleaning ALTER COLUMN start_date DATE;
-- Exploring Date Functions
-- Finish_date for exploration
SELECT 
  finish_date 
FROM 
  Cleaning;
top_10;
-- "Experiments" - running queries to see how the data would look with various changes.
-- Convert the value into a date object (timestamp)
SELECT 
  finish_date, 
  TRY_CAST(finish_date AS DATETIME) AS dt 
FROM 
  Cleaning;
-- Convert the date object into the desired format '%Y-%m-%d %H:'
SELECT 
  finish_date, 
  FORMAT(
    TRY_CAST(finish_date AS DATETIME), 
    'yyyy-MM-dd HH:mm:ss'
  ) AS dt 
FROM 
  Cleaning;
-- Extract only the date
SELECT 
  finish_date, 
  CONVERT(
    DATE, 
    TRY_CAST(finish_date AS DATETIME)
  ) AS fd 
FROM 
  Cleaning;
-- Extract only the time (timestamp)
SELECT 
  finish_date, 
  CONVERT(
    TIME, 
    TRY_CAST(finish_date AS DATETIME)
  ) AS hour_stamp 
FROM 
  Cleaning;
-- Splitting the elements of the time
SELECT 
  finish_date, 
  DATEPART(
    HOUR, 
    TRY_CAST(finish_date AS DATETIME)
  ) AS hrs, 
  DATEPART(
    MINUTE, 
    TRY_CAST(finish_date AS DATETIME)
  ) AS mnts, 
  DATEPART(
    SECOND, 
    TRY_CAST(finish_date AS DATETIME)
  ) AS sec, 
  FORMAT(
    TRY_CAST(finish_date AS DATETIME), 
    'HH:mm:ss'
  ) AS hour_stamp 
FROM 
  Cleaning;
-- Date Updates in the Table
-- Create a backup column for the finish_date
top_10;
ALTER TABLE 
  Cleaning 
ADD 
  date_backup NVARCHAR(MAX);
-- Add a backup column
UPDATE 
  Cleaning 
SET 
  date_backup = finish_date;
-- Copy the data from finish_date to the backup column
-- Update the date to a timestamp format (DATETIME)
UPDATE 
  Cleaning 
SET 
  finish_date = TRY_CAST(finish_date AS DATETIME) 
WHERE 
  finish_date <> '';
top_10;
-- Split finish_date into date and time
-- Create columns to store the new data
-- Add the 'dt' column of type DATE
ALTER TABLE 
  Cleaning 
ADD 
  dt DATE;
-- Add the 'hrs' column of type TIME
ALTER TABLE 
  Cleaning 
ADD 
  hrs TIME;
-- Update the values in these columns
UPDATE 
  Cleaning 
SET 
  dt = CONVERT(DATE, finish_date), 
  hrs = CONVERT(TIME, finish_date) 
WHERE 
  finish_date IS NOT NULL 
  AND finish_date <> '';
-- Set blank values to NULL
UPDATE 
  Cleaning 
SET 
  finish_date = NULL 
WHERE 
  finish_date = '';
-- Update the data type of finish_date
ALTER TABLE 
  Cleaning ALTER COLUMN finish_date DATETIME;
-- Check the data
top_10;
EXEC sp_columns 'Cleaning';
-- To describe the table
-- Add column to store age
ALTER TABLE 
  Cleaning 
ADD 
  age INT;
top_10;
-- Calculate age and update the 'age' column
UPDATE 
  Cleaning 
SET 
  age = DATEDIFF(
    YEAR, 
    birth_date, 
    GETDATE()
  );
-- Check the updated data
SELECT 
  name, 
  birth_date, 
  start_date, 
  age AS entry_age 
FROM 
  Cleaning;
