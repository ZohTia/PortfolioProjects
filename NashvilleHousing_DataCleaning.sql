
/*

Data Cleaning Project

*/

SELECT *
FROM NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

--Populate Propety Address Date

SELECT PropertyAddress, ParcelID
FROM NashvilleHousing
WHERE PropertyAddress is null

SELECT Tab1.ParcelID, Tab1.PropertyAddress, Tab2.ParcelID, Tab2.PropertyAddress, ISNULL(Tab1.PropertyAddress,Tab2.PropertyAddress)
FROM NashvilleHousing Tab1 JOIN NashvilleHousing Tab2
	 ON Tab1.ParcelID = Tab2.ParcelID
	 AND Tab1.[UniqueID ] <> Tab2.[UniqueID ]
WHERE Tab1.PropertyAddress is null

UPDATE Tab1
SET PropertyAddress = ISNULL(Tab1.PropertyAddress,Tab2.PropertyAddress)
FROM NashvilleHousing Tab1 JOIN NashvilleHousing Tab2
	 ON Tab1.ParcelID = Tab2.ParcelID
	 AND Tab1.[UniqueID ] <> Tab2.[UniqueID ]
WHERE Tab1.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)


SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
	   ,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertysplitAddress Nvarchar(225);

UPDATE NashvilleHousing
	SET PropertysplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD PropertysplitCity Nvarchar(225);

UPDATE NashvilleHousing
	SET PropertysplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
From NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnersplitAddress Nvarchar(225);

UPDATE NashvilleHousing
	SET OwnersplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnersplitCity Nvarchar(225);

UPDATE NashvilleHousing
	SET OwnersplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnersplitState Nvarchar(225);

UPDATE NashvilleHousing
	SET OwnersplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct SoldAsVacant, Count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY  SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No' 
	ELSE SoldAsVacant
END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No' 
	ELSE SoldAsVacant
END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing

)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

