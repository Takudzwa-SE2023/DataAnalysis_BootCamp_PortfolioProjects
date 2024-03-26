/* DATA CLEANING in SQL Queries*/


Select *
From PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------

--Standardize Date format Changing the date format


Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-------------------------------------------------------------------------------------------------------------------

--Populate propety Address data (some property doesnt have adresses(empty/ null values)

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

--bellow we will Join a table to its self to see if values equal each other as we are going to say if 
--ParceID has a PropertAddress, then that PareID's Owner address (wether null or not) 
--is the same as the Property Address

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is null


update a
SET PropertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is null


---------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, Sate) (only thing seperating them is a dilimeter(,)
-- going to use a character index, and a substring

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address -- -1 and +1 is to get rid of the comma
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

-- Another way of Doing whats above (using Parsename instead of Substring):


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 1)
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 1)

---------------------------------------------------------------------------------------------------------------

--Change the Y and N to Yes and No in "Sold as vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

--we  will now do a case statement saying, when soldAsVacant is = yes then make it Yes,
--and the same thing for N and No

Select SoldAsVacant
, CASE When SoldAsVacant ='Y' THEN 'Yes'
       When SoldAsVacant ='N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant ='Y' THEN 'Yes'
       When SoldAsVacant ='N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------
--Removing Duplicates
--CTE and some windows function to find were there are duplicate values
--write out a query and then put it into a cte

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
						)row_num


From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
order by PropertyAddress


-----------------------------------------------------------------------------------------------
-- Selete Unuses Columns(not done to raw data, its intended for practice)

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate


-----------------------------------------------------------------------------------------------