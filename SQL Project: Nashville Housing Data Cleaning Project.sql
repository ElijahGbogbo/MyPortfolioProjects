/*

Cleaning the Housing Data in Our SQL Queries

*/



Select *
From PortfolioProject.dbo.NashvilleHousingData



---------------------------------------------------------------------------------------------------------------------

-- Standardize the Date Format

Alter Table PortfolioProject.dbo.NashvilleHousingData
Add SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousingData
Set SaleDateConverted = Convert(Date, SaleDate)

Select SaleDate, SaleDateConverted
From PortfolioProject.dbo.NashvilleHousingData



--------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From PortfolioProject.dbo.NashvilleHousingData
--Where PropertyAddress is null
Order by ParcelID

Select nashA.ParcelID, nashA.PropertyAddress, nashB.ParcelID, nashB.PropertyAddress, ISNULL(nashA.PropertyAddress, nashB.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousingData as nashA
Join PortfolioProject.dbo.NashvilleHousingData as nashB
	On nashA.ParcelID = nashB.ParcelID
	And nashA.[UniqueID ] <> nashB.[UniqueID ]
Where nashA.PropertyAddress is null

Update nashA
Set PropertyAddress = ISNULL(nashA.PropertyAddress, nashB.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousingData as nashA
Join PortfolioProject.dbo.NashvilleHousingData as nashB
	On nashA.ParcelID = nashB.ParcelID
	And nashA.[UniqueID ] <> nashB.[UniqueID ]
Where nashA.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into individual columns (Address, City, State)

Select *
--PropertyAddress
From PortfolioProject.dbo.NashvilleHousingData

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousingData

Alter Table PortfolioProject.dbo.NashvilleHousingData
Add PropertySplitAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingData
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table PortfolioProject.dbo.NashvilleHousingData
Add PropertySplitCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingData
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousingData



Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousingData

Select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousingData

Alter Table PortfolioProject.dbo.NashvilleHousingData
Add OwnerSplitAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingData
Set OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table PortfolioProject.dbo.NashvilleHousingData
Add OwnerSplitCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingData
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table PortfolioProject.dbo.NashvilleHousingData
Add OwnerSplitState nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingData
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


Select *
From PortfolioProject.dbo.NashvilleHousingData



-----------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" Field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousingData
Group by SoldAsVacant
Order by 2

Select SoldAsVacant, 
Case
	When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
End as SoldAsVacantModified
From PortfolioProject.dbo.NashvilleHousingData

Update PortfolioProject.dbo.NashvilleHousingData
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
						When SoldAsVacant = 'N' then 'No'
						Else SoldAsVacant
						End

Select SoldAsVacant
From PortfolioProject.dbo.NashvilleHousingData



------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE As
(Select *, 
ROW_NUMBER() Over 
(Partition by ParcelID, 
			  PropertyAddress, 
			  SalePrice, 
			  SaleDate, 
			  LegalReference
			  Order by
			  UniqueID) as Row_Num
From PortfolioProject.dbo.NashvilleHousingData
--Order by ParcelID
)
Select *
From RowNumCTE
Where Row_Num > 1

Select *
From PortfolioProject.dbo.NashvilleHousingData



-----------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousingData

Alter Table PortfolioProject.dbo.NashvilleHousingData
Drop Column SaleDate, OwnerAddress, PropertyAddress, TaxDistrict













