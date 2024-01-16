Select *
From project.dbo.NashvilleHousing

..........................................................

--Standardize date format


Select SaleDateNew, CONVERT(Date,SaleDate)
From project.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateNew Date;

Update NashvilleHousing
SET SaleDateNew = CONVERT(Date,SaleDate)



-- Populate Property Address data

SELECT *
From project.dbo.NashvilleHousing
---Where PropertyAddress is NULL
order by ParcelID



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From project.dbo.NashvilleHousing a
JOIN project.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From project.dbo.NashvilleHousing a
JOIN project.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null



----------------------------------------------------------------------------------------------------------


--Breaking out Address Into Individual Columns (Address, City, State)

SELECT PropertyAddress
From project.dbo.NashvilleHousing
---Where PropertyAddress is NULL
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
FROM Project.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing 
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


Select *
From project.dbo.NashvilleHousing



Select OwnerAddress
From project.dbo.NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From project.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing 
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From project.dbo.NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From project.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2



Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END
From project.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END


----------------------------------------------------------------------------------------------------------------

--Remove Duplicates 


WITH RowNumCTE AS(
Select *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 Propertyaddress,
					 salePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY 
						UniqueID
						) row_num

From project.dbo.NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
where row_num > 1


----Delete Unused Columns



Select *
From project.dbo.NashvilleHousing

ALTER TABLE project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE project.dbo.NashvilleHousing
DROP COLUMN SaleDate
