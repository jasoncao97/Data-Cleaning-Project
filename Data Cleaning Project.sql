-- Cleaning Data Through SQL Queries

SELECT *
FROM NashHousingData



-- Populate Property Address Data

SELECT *
FROM NashHousingData
WHERE PropertyAddress IS NULL 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashHousingData a
JOIN NashHousingData b 
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID 
WHERE a.PropertyAddress  IS NULL


UPDATE NashHousingData a
JOIN NashHousingData b 
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID 
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress  IS NULL



-- Breaking Out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashHousingData

SELECT 
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1) AS address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1,  LENGTH(PropertyAddress)) AS city
FROM NashHousingData

ALTER TABLE NashHousingData 
ADD PropertySplitAddress varchar(255);

UPDATE NashHousingData 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1) 

ALTER TABLE NashHousingData 
ADD PropertySplitCity varchar(255);

UPDATE NashHousingData 
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress))

SELECT *
FROM NashHousingData 



-- Owner Address

SELECT OwnerAddress 
FROM NashHousingData

SELECT 
SUBSTRING_INDEX(OwnerAddress, ',', 1) AS address,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS city, 
SUBSTRING_INDEX(OwnerAddress, ',', -1) AS state
FROM NashHousingData

ALTER TABLE NashHousingData 
ADD OwnerSplitAddress varchar(255);

UPDATE NashHousingData 
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1) 

ALTER TABLE NashHousingData 
ADD OwnerSplitCity varchar(255);

UPDATE NashHousingData 
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) 

ALTER TABLE NashHousingData 
ADD OwnerSplitState varchar(255);

UPDATE NashHousingData 
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1) 

SELECT *
FROM NashHousingData 



-- Change Y and N to Yes and No in "Sold as vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashHousingData 
GROUP BY 1
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant 
	 END
FROM NashHousingData

UPDATE NashHousingData 
SET SoldAsVacant = (
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant 
		 END)

		 
		 
-- Remove Duplicates 

WITH cte AS (
SELECT UniqueID,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				 	UniqueID
				 	) AS row_num
FROM NashHousingData
)
DELETE n
FROM NashHousingData n
JOIN cte c
	ON n.UniqueID = c.UniqueID
WHERE row_num > 1



-- Delete Unused Columns

ALTER TABLE NashHousingData 
	DROP COLUMN OwnerAddress, 
	DROP COLUMN PropertyAddress,
	DROP COLUMN TaxDistrict;







 