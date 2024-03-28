-- data cleaning project

Select * 
From PortfolioProjects.dbo.NashvilleHousing

-- standardize date format

Select SaleDateConverted, CONVERT (Date, SaleDate)
From PortfolioProjects.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate) 

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date; 

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

-- populate property address data 

Select *
From PortfolioProjects.dbo.NashvilleHousing
--Where PropertyAddress is null
Order By ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a
Join PortfolioProjects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a
Join PortfolioProjects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- breaking out address into individual columns (address, city, state)

Select PropertyAddress
From PortfolioProjects.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVarChar(255); 

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVarChar(255); 

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select* 
From PortfolioProjects.dbo.NashvilleHousing




Select OwnerAddress
From PortfolioProjects.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.') ,3),
PARSENAME(REPLACE(OwnerAddress,',','.') ,2),
PARSENAME(REPLACE(OwnerAddress,',','.') ,1)
From PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVarchar(225); 

Update NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') ,3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVarchar(225); 

Update NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.') ,2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVarchar(225); 

Update NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.') ,1)

Select * 
From PortfolioProjects.dbo.NashvilleHousing

-- Change Y and N to Yes and No in 'Sold as Vacant' field 

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjects.dbo.NashvilleHousing
Group By SoldAsVacant
Order by 2

Select SoldAsVacant, 
	Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From PortfolioProjects.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End

-- Remove duplicates
With RowNumCTE AS(
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
From PortfolioProjects.dbo.NashvilleHousing
--ORDER BY ParcelID
)
Delete
From RowNumCTE
Where row_num > 1
--Order By PropertyAddress


-- Delete unused columns

Select * 
From PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN SaleDate

-- data is now much more usable, friendly and standardized now! 