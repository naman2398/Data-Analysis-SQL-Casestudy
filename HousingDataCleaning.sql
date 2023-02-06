/*

Cleaning Data using SQL Queries

*/

select * from HousingData.dbo.NashvilleHousing


--Standard Sales Date

select saledate, convert(date,saledate)
from HousingData.dbo.NashvilleHousing

Alter table HousingData.dbo.NashvilleHousing
add SaleDateConverted Date;

update HousingData.dbo.NashvilleHousing
set SaleDateConverted = convert(date,saledate)

-- Populate Property Address

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(b.PropertyAddress,a.PropertyAddress)
from HousingData.dbo.NashvilleHousing a join HousingData.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID and a.[UniqueID ] != b.[UniqueID ]
where b.PropertyAddress is null

Update b
set propertyaddress = isnull(b.PropertyAddress,a.PropertyAddress)
from HousingData.dbo.NashvilleHousing a join HousingData.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID and a.[UniqueID ] != b.[UniqueID ]
where b.PropertyAddress is null

-- Breaking Address into individual columns (address, city, state)
--1. Property Address
select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from HousingData.dbo.NashvilleHousing

Alter table HousingData.dbo.NashvilleHousing
add PropertySplitAddress nvarchar(255);

update HousingData.dbo.NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter table HousingData.dbo.NashvilleHousing
add PropertySplitCity nvarchar(255);

update HousingData.dbo.NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--2. Owner Address
select
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as State
from HousingData.dbo.NashvilleHousing

Alter table HousingData.dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update HousingData.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter table HousingData.dbo.NashvilleHousing
add OwnerSplitCity nvarchar(255);

update HousingData.dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter table HousingData.dbo.NashvilleHousing
add OwnerSplitState nvarchar(255);

update HousingData.dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Change Y to Yes and N to No

select SoldAsVacant,
case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from HousingData.dbo.NashvilleHousing

update HousingData.dbo.NashvilleHousing
set SoldAsVacant = case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

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

From HousingData.dbo.NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1



