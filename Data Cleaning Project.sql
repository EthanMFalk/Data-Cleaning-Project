/*


Cleaning data in SQL queries


*/

Select *
From dbo.NashData;


--------------------------------------------------------------------------------------------------------


-- Standarize Date Format


Select SaleDateConverted, convert(Date,SaleDate)
From dbo.NashData;

update NashData
Set SaleDate = convert(Date,SaleDate)

--If it doesn't update properly

Alter Table NashData
Add SaleDateConverted Date;

update NashData
Set SaleDateConverted = convert(Date,SaleDate)


--------------------------------------------------------------------------------------------------------


-- Populate Property Address data


Select *
From dbo.NashData
ORDER BY ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashData a
JOIN dbo.NashData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashData a
JOIN dbo.NashData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From dbo.NashData

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address

From dbo.NashData


Alter Table NashData
Add PropertySplitAddress Nvarchar(255);

update NashData
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


Alter Table NashData
Add PropertySplitCity Nvarchar(255);

update NashData
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))



Select *
From NashData




Select OwnerAddress
From NashData



Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
 ,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
 ,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From NashData



Alter Table NashData
Add OwnerSplitAddress Nvarchar(255);

update NashData
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashData
Add OwnerSplitCity Nvarchar(255);

update NashData
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter Table NashData
Add OwnerSplitState Nvarchar(255);

update NashData
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


Select *
From nashdata


--------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashData
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END
From NashData


Update NashData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


--------------------------------------------------------------------------------------------------------


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
				 
From NashData
--ORDER BY ParcelID
)
Select *
From RowNUMCTE
Where Row_num > 1
Order by PropertyAddress


Select *
From NashData


--------------------------------------------------------------------------------------------------------


-- Delete Unused Columns

Select *
From NashData

ALTER TABLE NashData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


--------------------------------------------------------------------------------------------------------