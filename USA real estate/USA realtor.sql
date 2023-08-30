--Backup database
 BACKUP DATABASE [POST-PRAC]
 TO DISK = 'C:/backups/POST-PRAC.bak'
 WITH STATS
 --WITH PASSWORD =****  --for if i want it to have passwords;

-- sp_helpdb 'POST-PRAC'

 SELECT *
  FROM [POST-PRAC]..realtor
  ORDER BY [unique id]

  --Sold_date to YMD from MDY OR alter table *** alter column sold_date date;
  UPDATE [POST-PRAC]..realtor
  SET sold_date = CONVERT(date, sold_date)

  --viewing column name and its datatype
  USE [POST-PRAC]
GO
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'realtor';

  	--RENAMINING COLUMN, eventually changed it from the object explorer.
	EXEC sp_rename'[dbo].[realtor].[bath]', 'bathroom','COLUMN';
	EXEC sp_rename'[dbo].[realtor].[bed]', 'bedroom','COLUMN';

  --Replace the underscores with space in status column
  UPDATE   [POST-PRAC].[dbo].[realtor]
  SET status = replace(status,'_',' ')

  --ADD 'ready' to 'for sale building status
  UPDATE [POST-PRAC]..realtor
  SET status =CONCAT('ready ', status)
  WHERE status like( 'for sale')

  --zipcode is inappropriate, parse an appropriate zipcode from full address, used right but still looking for a better delimiter
  SELECT 
  --SUBSTRING(full_address, 1, CHARINDEX(',',full_address)-1) Address,
     -- SUBSTRING(full_address, Charindex(',', full_address) + 1,Len(full_address) - Charindex(',', Reverse(full_address)) - Charindex(',', full_address)),
	  -- RIGHT(full_address, Charindex(',', Reverse(full_address)) - 1)

  RIGHT(full_address,5)	ZipCode			--used 5 because all the zip codes are 5 digits
  FROM [POST-PRAC].[dbo].[realtor]

  ALTER TABLE  [POST-PRAC].[dbo].[realtor]
  ADD ZipCode CHAR(5);

  UPDATE   [POST-PRAC].[dbo].[realtor]
  SET zipCode = RIGHT(full_address,5)

   BEGIN TRANSACTION --used transaction for cleaning where i used DML functions update and delete actually.
  SELECT @@TRANCOUNT trans --to know if i have an uncommited transaction

  --DELETE DUPLICATE if there is
WITH Rownumcte AS(
  SELECT *,
	ROW_NUMBER() OVER(
					PARTITION BY status
								 ,Price
								 ,bedroom
								 ,bathroom
								 ,acre_lot
								 ,city
								 ,state
								 ,house_size
								 ,street
								 ,sold_date
					ORDER BY status ASC
					) RowNum
	 FROM [POST-PRAC].[dbo].[realtor])
	 
	DELETE 
	FROM Rownumcte
	WHERE RowNum > 1

	--DROPPING UNUSED COLUMN
	ALTER TABLE   [POST-PRAC].[dbo].[realtor]
	DROP COLUMN full_address,zip_code

	--ADDING a primary key [unique id] to the existing table giving it an identity starting at number '1' with an auto-increment of '1'
	ALTER TABLE [POST-PRAC].[dbo].[realtor]
	ADD [Unique id] int IDENTITY(1,1) PRIMARY KEY

	--FILLING missing values in bedroom, bathroom, acre_lot, house_size with there average respectively
	--An aggregate may not appear in the set list of an UPDATE statement.

	SELECT round(avg(acre_lot),0),round(avg(bedroom),0),round(avg(bathroom),0),round(avg(house_size),0)
	from [POST-PRAC]..realtor
	
	BEGIN TRAN --Decided to use a transanction since i wasnt sure and i committed it after several trails and errors.
	SELECT @@TRANCOUNT -- USED IT FOR CHECKING IF I HAVE ANY UNCOMMITTED TRANSACTION ACTIVE

	WITH Bathfill AS(
	SELECT round(avg(bathroom),0) AS RndAvgBath
	from [POST-PRAC]..realtor)
		UPDATE [POST-PRAC].[dbo].[realtor]
	SET bathroom =ISNULL(bathroom,RndAvgBath)
	FROM Bathfill
	
	WITH Bedfill AS(
	SELECT round(avg(bedroom),0) AS RndAvgBed
	from [POST-PRAC]..realtor)
		UPDATE [POST-PRAC].[dbo].[realtor]
	SET bedroom =ISNULL(bedroom,RndAvgBed)
	FROM Bedfill
	
	WITH Acrefill AS(
	SELECT round(avg(acre_lot),0) AS RndAvgAcre
	from [POST-PRAC]..realtor)
		UPDATE [POST-PRAC].[dbo].[realtor]
	SET acre_lot =ISNULL(acre_lot,RndAvgAcre)
	FROM Acrefill

	WITH Housefill AS(
	SELECT round(avg(house_size),0) AS RndAvgHouse
	from [POST-PRAC]..realtor)
		UPDATE [POST-PRAC].[dbo].[realtor]
	SET house_size =ISNULL(house_size,RndAvgHouse)
	FROM Housefill

	--EXPLORATORY DATA ANALYSIS

--Total number of house
SELECT count (*) number_of_house
FROM [POST-PRAC]..realtor

--Number of house by status
SELECT DISTINCT status, COUNT(Status) [Number of house]
FROM [POST-PRAC]..realtor
GROUP BY STATUS

--Average price for [ready for sale] and [ready to build] houses
SELECT DISTINCT status, AVG(price) AVGprice
FROM [POST-PRAC]..realtor
GROUP BY status

--Average housing price, most expensive and least expensive
SELECT AVG(price) AVGprice, MAX(price) MOSTexpensive, MIN(price) LEASTexpensive
FROM [POST-PRAC]..realtor

--Average house size, max house size and min house size
SELECT AVG(house_size) AVGhouse_size, MAX(house_size) MAXhouse_size, MIN(house_size) MINhouse_size
FROM [POST-PRAC]..realtor

--Most populated state and sity with least populated state and city
SELECT MAX(state) most_populated_state, MAX(city) most_populated_city, MIN(state) least_filled_state, MIN(city) least_filled_city
FROM [POST-PRAC]..realtor

--AVERAGE acre_lot, highest and and lowest acre_lot
SELECT AVG(acre_lot) AVGacre_lot, MAX(acre_lot) HighestAcre_lot, MIN(acre_lot) LowestAcre_lot
FROM [POST-PRAC]..realtor

--Top 5 housing price By house_size and street, city,state
SELECT TOP 5 price, house_size,street,city,state
FROM [POST-PRAC]..realtor
ORDER BY price DESC

--top 10 city, street where housing prices are expensive
SELECT TOP 10 CONCAT_WS(',',city,state), price, acre_lot
FROM [POST-PRAC]..realtor
ORDER BY price DESC

--top 10 Location where housing prices are cheap
SELECT TOP 10 CONCAT_WS(',', street,city,state) AS Location, price
FROM [POST-PRAC]..realtor
ORDER BY price 



