/*

Cleaning Data in SQL Queries

*/

---------------------------------------------------

 select *
from PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------

--Standadize date format

select SaleDateConverted, CONVERT(Date,Saledate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(Date,Saledate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,Saledate)

----------------------------------------------

--Populate Property Address data

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress Is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


------------------------------------------------------

--Breaking out Address into individual Columns (Address, City, State)

 select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress Is null
--order by ParcelID


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing


select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
, PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
, PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


-------------------------------------------------------------------------
--Changing y and n to Yes and No in "sold as vacant" Field

select Distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2 

select SoldAsVacant
, CASE When SoldAsVacant = 'Y' then 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
From PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END

-------------------------------------------------------------------------------

--Removing Duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueId
				 )row_num
From PortfolioProject.dbo.NashvilleHousing
)
Delete
From RowNumCTE
where row_num > 1
--order by PropertyAddress


----------------------------------------------------------------------------------

--Delete Unused Tables

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop column OwnerAddress,TaxDistrict,PropertyAddress,SaleDate

select *
From PortfolioProject.dbo.NashvilleHousing