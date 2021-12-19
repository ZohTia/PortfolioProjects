/*

Data Cleaning Project

*/

SELECT *
FROM Levels_Fyi_Salary_Data

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER Table Levels_Fyi_Salary_Data
ADD DateConverted Date

UPDATE Salary_Data
SET DateConverted = CONVERT(Date,timestamp)

--------------------------------------------------------------------------------------------------------------------------

----Breaking out Address into Individual Columns (Address, City, State)

ALTER TABLE Levels_Fyi_Salary_Data
ADD City Nvarchar(225);

UPDATE Levels_Fyi_Salary_Data
	SET City = PARSENAME(REPLACE(location, ',', '.'), 3)

ALTER TABLE Levels_Fyi_Salary_Data
ADD Abbrv Nvarchar(225);

UPDATE Levels_Fyi_Salary_Data
	SET Abbrv = PARSENAME(REPLACE(location, ',', '.'), 2)

ALTER TABLE Levels_Fyi_Salary_Data
ADD State Nvarchar(225);

UPDATE Salary_Data
	SET State = PARSENAME(REPLACE(location, ',', '.'), 1)

--Populate City

UPDATE a
SET city = ISNULL(a.city, a.abbrv)
FROM Levels_Fyi_Salary_Data a JOIN Levels_Fyi_Salary_Data b 
	 ON a.dmaid = b.dmaid 
	 AND a.cityid <> b.cityid 
WHERE a.City is null

---------------------------------------------------------------------------------------------------------

-- Change Title: Senior Software Engineer to NA  in "gender" field

SELECT Gender,COUNT(Gender)
FROM Levels_Fyi_Salary_Data
GROUP BY Gender

SELECT Gender,
CASE
	WHEN Gender = 'Title: Senior Software Engineer' THEN 'NA'
	ELSE Gender
END
FROM Levels_Fyi_Salary_Data

UPDATE Levels_Fyi_Salary_Data
	   SET Gender = CASE
	WHEN Gender = 'Title: Senior Software Engineer' THEN 'NA'
	ELSE Gender
END


---------------------------------------------------------------------------------------------------------
--Delete Unused Columns

ALTER Table Levels_Fyi_Salary_Data
DROP COLUMN abbrv, level, tag, location, dmaid, rowNumber, Some_College, Race_Asian, Race_White, Race_Two_Or_More, Race_Black, Race_Hispanic, otherdetails






