----------------------------------------------------------------------------------------------
-- Standardize date format (Remove the time)
SELECT *
FROM housingdata..Nashvillehousing

SELECT saledateupdated , CONVERT(date,saledate)
FROM housingdata..Nashvillehousing

UPDATE Nashvillehousing
SET SaleDate = CONVERT(date, saledate)

--  ::

ALTER TABLE NashvilleHousing
ADD Saledateupdated date

UPDATE Nashvillehousing
SET Saledateupdated = CONVERT (date,saledate)

--------------------------------------------------------------------------------------------------------------
--Populate Property Address

Select a.UniqueID ,a.ParcelID , a.PropertyAddress ,b.[UniqueID ], b.ParcelID , b.PropertyAddress 
FROM housingdata..Nashvillehousing a
JOIN housingdata..Nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is NULL

-- ::

UPDATE a
SET propertyaddress = ISNULL (a.propertyaddress , b.propertyaddress)
FROM housingdata..Nashvillehousing a
JOIN housingdata..Nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is NULL

-------------------------------------------------------------------------------------------------
-- Breaking out address 

SELECT SUBSTRING(propertyaddress , 1, CHARINDEX(',' , PropertyAddress)-1 ) as Address , 
	SUBSTRING(propertyaddress ,  CHARINDEX(',' , PropertyAddress)+1 , len(propertyaddress) ) as City
FROM housingdata..Nashvillehousing

--::
ALTER TABLE Nashvillehousing
ADD NewAddress nvarchar(255)

UPDATE Nashvillehousing
SET NewAddress = SUBSTRING(propertyaddress , 1, CHARINDEX(',' , PropertyAddress)-1 ) 

ALTER TABLE Nashvillehousing
ADD City nvarchar(255)

UPDATE Nashvillehousing
SET City = SUBSTRING(propertyaddress ,  CHARINDEX(',' , PropertyAddress)+1 , len(propertyaddress) )

select *
from housingdata..Nashvillehousing

-- for owner's address:

SELECT PARSENAME(REPLACE(owneraddress, ',' , '.' ),3)
	, PARSENAME(REPLACE(owneraddress, ',' , '.' ),2)
	, PARSENAME(REPLACE(owneraddress, ',' , '.' ),1)
FROM housingdata..Nashvillehousing

ALTER TABLE nashvillehousing
ADD owneraddresssplit nvarchar(255)

UPDATE Nashvillehousing
SET owneraddresssplit = PARSENAME(REPLACE(owneraddress, ',' , '.' ),3)

ALTER TABLE nashvillehousing
ADD ownercityssplit nvarchar(255)

UPDATE Nashvillehousing
SET ownercityssplit = PARSENAME(REPLACE(owneraddress, ',' , '.' ),2)

ALTER TABLE nashvillehousing
ADD ownerstatesplit nvarchar(255)

UPDATE Nashvillehousing
SET ownerstatesplit = PARSENAME(REPLACE(owneraddress, ',' , '.' ),1)

select *
from housingdata..Nashvillehousing
-------------------------------------------------------------------------------------------------
-- Change all the 'Y' and 'N' to 'Yes' and 'No' in soldasvacant

SELECT distinct(soldasvacant) , count(soldasvacant)
FROM housingdata..Nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT soldasvacant ,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM housingdata..Nashvillehousing

--::

UPDATE Nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH Rownum AS (
SELECT * ,
	ROW_NUMBER() OVER (
	PARTITION BY parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 ORDER BY 
					uniqueid
				  ) row_num
FROM housingdata..Nashvillehousing
)
SELECT *
FROM Rownum
WHERE row_num>1
----------------------------------------------------------------------------------------------------