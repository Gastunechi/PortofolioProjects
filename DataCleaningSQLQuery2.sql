/* Data cleaning In SQL*/

SELECT *
FROM dbo.NashvilleHousing$

-- Standardize Date format


update dbo.NashvilleHousing$
set SaleDate = CONVERT(date,SaleDate)


alter table dbo.NashvilleHousing$
add SaleDateConverted date;


update dbo.NashvilleHousing$
set SaleDateConverted = CONVERT(date,SaleDate)


SELECT SaleDateConverted
FROM dbo.NashvilleHousing$




------------------------------------------------------------------------------------------------------------------------------------------
--Populate Property Address Data


SELECT *
FROM dbo.NashvilleHousing$
Where PropertyAddress is null


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing$ a
JOIN dbo.NashvilleHousing$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null     

/* Checking the Where the property address has null values by joining the same table on the same parcelID field value 
And replacing the Null values with the values of Propertyaddress that have the same parcelID*/

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing$ a
JOIN dbo.NashvilleHousing$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null

/* Updating the table with the Replaced null values */


------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out Property Address into individual columns (Address, City, State)


SELECT PropertyAddress
FRom dbo.NashvilleHousing$

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as city
FROM dbo.NashvilleHousing$

/* Split the property address into Address and city field*/

alter table dbo.NashvilleHousing$
add PropertySplitAddress NVarchar(255);

update dbo.NashvilleHousing$
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)



alter table dbo.NashvilleHousing$
add PropertySplitCity NVarchar(255);

update dbo.NashvilleHousing$
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
FROM dbo.NashvilleHousing$

/* Adding the splitted fields to the initial Table*/



------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out Owner Address into individual columns (Address, City, State)

SELECT *
FROM dbo.NashvilleHousing$
WHERE OwnerAddress is not null

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) as OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnerState
FROM dbo.NashvilleHousing$

ALTER TABLE dbo.NashVilleHousing$
ADD OwnerSplitAddress NVarchar(255);

UPDATE dbo.NashVilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) 


ALTER TABLE dbo.NashVilleHousing$
ADD OwnerSplitCity NVarchar(255);


UPDATE dbo.NashVilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) 


ALTER TABLE dbo.NashVilleHousing$
ADD OwnerSplitState NVarchar(255);

UPDATE dbo.NashVilleHousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) 

/*Adding the splitted field of owner to the table*/



------------------------------------------------------------------------------------------------------------------------------------------


--Change Y and N to Yes and No in "Sold As Vacant" field

Select distinct SoldAsVacant, count(SoldAsVacant)
from dbo.NashvilleHousing$
group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' then  'Yes'
	 When SoldAsVacant = 'N' then  'No'
	 ELSE SoldAsVacant
	 END
From dbo.NashvilleHousing$


UPDATE dbo.NashvilleHousing$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then  'Yes'
				   When SoldAsVacant = 'N' then  'No'
				   ELSE SoldAsVacant
				   END



------------------------------------------------------------------------------------------------------------------------------------------


--Remove Duplicates
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				   UniqueID
				   ) row_num
From dbo.NashvilleHousing$
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1




------------------------------------------------------------------------------------------------------------------------------------------


--Delete unused columns

Select *
From dbo.NashvilleHousing$

ALTER TABLE dbo.NashvilleHousing$
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE dbo.NashvilleHousing$
DROP COLUMN SaleDate