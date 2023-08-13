SELECT *
FROM [POST-PRAC].dbo.NASHAY
where PropertyAddress is null

--ADJUST SALEDATE, its a datetime format that needs to be a date. the time aint useful
SELECT newsaledate, CAST(saledate AS date)  --or CONVERT(date , saledate) 
FROM NASHAY

UPDATE NASHAY
SET SaleDate = CAST(saledate AS date)  -- didnt workout

ALTER TABLE NASHAY
ADD newsaledate DATE;

UPDATE NASHAY
SET newsaledate = CAST(saledate AS date)


--ADJUSTING PROPERTY ADDRESS
SELECT PropertyAddress
FROM NASHAY
WHERE PropertyAddress is NULL --NOTE THAT PROPERTY ADDRESS SHOULDNT BE NULL, TWAS FOUND OUT THAT SAME PARCELID FOR EQUAL PROPTTAD

SELECT nashA.ParcelID, nashA.PropertyAddress, nashB.ParcelID, nashB.PropertyAddress, ISNULL(nashA.PropertyAddress, nashB.PropertyAddress)
FROM NASHAY nashA
 JOIN NASHAY nashB
 ON nashA.ParcelID = nashB.ParcelID
 AND nashA.[UniqueID ] <> nashB.[UniqueID ]
WHERE nashA.PropertyAddress is null
--SELFJOIN
/*SELECT A.CustomerName AS CustomerName1, B.CustomerName AS CustomerName2, A.City
FROM Customers A, Customers B
WHERE A.CustomerID <> B.CustomerID
AND A.City = B.City
ORDER BY A.City;*/

UPDATE nashA		--cos i have joins in the update stamement so imma gonna use the aliases
SET PropertyAddress = ISNULL(nashA.PropertyAddress, nashB.PropertyAddress)
FROM NASHAY nashA
 JOIN NASHAY nashB
 ON nashA.ParcelID = nashB.ParcelID
 AND nashA.[UniqueID ] <> nashB.[UniqueID ]
WHERE nashA.PropertyAddress is null


--splitting FULL address into ADDRESS , CITY , STATE. PROPERTY ADDRESS FIRST
SELECT PropertyAddress
FROM NASHAY

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) Address,
RIGHT(propertyAddress,LEN(propertyAddress)- CHARINDEX(',',propertyAddress)) City
FROM NASHAY


ALTER TABLE NASHAY
ADD Address4property nvarchar(255);

UPDATE NASHAY
SET Address4property = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NASHAY
ADD City4property nvarchar(255);

UPDATE NASHAY
SET City4property = RIGHT(propertyAddress,LEN(propertyAddress)- CHARINDEX(',',propertyAddress))

SELECT City4property,Address4property,PropertyAddress
FROM NASHAY

--splitting FULL address into ADDRESS , CITY , STATE. OWNER ADDRESS 
SELECT OwnerAddress
FROM NASHAY

SELECT 
PARSENAME(REPLACE(Owneraddress,',','.'),3) ADDRESS,--LEFT(owneraddress, CHARINDEX(',',owneraddress)-1) address, --PARSENAME, A VERY USEFULFUNCTION IN DELIMITER STUFFS
PARSENAME(REPLACE(Owneraddress,',','.'),2) CITY,
PARSENAME(REPLACE(Owneraddress,',','.'),1) STATE
FROM NASHAY

ALTER TABLE NASHAY
ADD Address4owner nvarchar(255);

UPDATE NASHAY
SET Address4owner = PARSENAME(REPLACE(Owneraddress,',','.'),3)


ALTER TABLE NASHAY
ADD City4owner nvarchar(255);

UPDATE NASHAY
SET City4owner = PARSENAME(REPLACE(Owneraddress,',','.'),2)


ALTER TABLE NASHAY
ADD State4owner nvarchar(255);

UPDATE NASHAY
SET State4owner = PARSENAME(REPLACE(Owneraddress,',','.'),1)

SELECT Address4owner, City4owner, State4owner
FROM NASHAY

--CHANGING Y AND N IN "SOLD AS VACANT" TO YES AND NO.

SELECT SoldAsVacant
FROM NASHAY
WHERE SoldAsVacant = 'N'
	OR SoldAsVacant = 'Y'

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'N' THEN 'NO'
		WHEN SoldAsVacant = 'Y' THEN 'YES'
		ELSE SoldAsVacant
		END
FROM NASHAY

UPDATE NASHAY
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'NO'
		WHEN SoldAsVacant = 'Y' THEN 'YES'
		ELSE SoldAsVacant
		END

--DELETE DUPLICATE
WITH CTE_RowNum AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID
				,PropertyAddress
				,Saledate
				,Saleprice
				,Legalreference
	ORDER BY
				UniqueID
						) RowNum
FROM NASHAY)

DELETE 
FROM CTE_RowNum
WHERE RowNum <> 1


--ELIMINATE UNUSED COLUMNS
--ALTER TABLE NASHAY
--DROP COLUMN COLUMName1, COLUMNname2