                                              
                                              --*** CLEANING DATA IN SQL QUERIES ***--
----------------------------------------------------------------------------------------------------------------------------                                               
SELECT * 
FROM ProjectPortfolio..NashvilleHousing

--------------------------------------------STANDARDIZE DATA FORMAT OF SALESDATE--------------------------------------------

SELECT SALEDATECONVERTED
FROM ProjectPortfolio..NashvilleHousing
ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD SALEDATECONVERTED DATE ;
UPDATE ProjectPortfolio..NashvilleHousing
SET SALEDATECONVERTED = CONVERT(date,SaleDate)

--------------------------------------------POPULATE PROPERTY ADDRESS DATA--------------------------------------------------

SELECT *
FROM ProjectPortfolio..NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID ,a.PropertyAddress ,b.ParcelID ,b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress) 
FROM ProjectPortfolio..NashvilleHousing a 
JOIN ProjectPortfolio..NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL 

UPDATE a 
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) 
FROM ProjectPortfolio..NashvilleHousing a 
JOIN ProjectPortfolio..NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL 

SELECT [UniqueID ],PropertyAddress
FROM ProjectPortfolio..NashvilleHousing
order by 2

-----------------------------BREAKING OUT ADDRESS INTO INDIVIDUALS COLUMNS (ADDRESS , CITY ,STATE)-------------------------------

SELECT 
SUBSTRING(PropertyAddress , 1 , CHARINDEX(',',PropertyAddress ) -1) AS Address,
SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress ) +1,len(PropertyAddress)) AS City
FROM ProjectPortfolio..NashvilleHousing

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD PropertySplitAddress nvarchar(255) ;
UPDATE ProjectPortfolio..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress , 1 , CHARINDEX(',',PropertyAddress ) -1) 

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD PropertySplitCity nvarchar(255) ;
UPDATE ProjectPortfolio..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress ) +1,len(PropertyAddress)) 

--------------------------------------------------------USING ANOTHER METHOD----------------------------------------------------

SELECT 
parsename(REPLACE(OwnerAddress,',','.'),3) as Address
,parsename(REPLACE(OwnerAddress,',','.'),2) as City
,parsename(REPLACE(OwnerAddress,',','.'),1) as State
FROM ProjectPortfolio..NashvilleHousing

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255) ;
UPDATE ProjectPortfolio..NashvilleHousing
SET OwnerSplitAddress = parsename(REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD OwnerSplitCity nvarchar(255) ;
UPDATE ProjectPortfolio..NashvilleHousing
SET OwnerSplitCity = parsename(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD OwnerSplitState nvarchar(255) ;
UPDATE ProjectPortfolio..NashvilleHousing
SET OwnerSplitState = parsename(REPLACE(OwnerAddress,',','.'),1)

------------------------------------------CHANGE Y AND N TO YES AND NO IN SOLD AS VACANT FIELD------------------------------------

SELECT DISTINCT(SoldAsVacant) , count(SoldAsVacant)
FROM ProjectPortfolio..NashvilleHousing 
Group by SoldAsVacant
order by SoldAsVacant

SELECT DISTINCT(SoldAsVacant)
,CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	  WHEN SoldAsVacant='N' THEN 'No'
	  ELSE SoldAsVacant
 END
FROM ProjectPortfolio..NashvilleHousing 

UPDATE ProjectPortfolio..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	  WHEN SoldAsVacant='N' THEN 'No'
	  ELSE SoldAsVacant
 END

-------------------------------------------------------REMOVING DUPLICATES----------------------------------------------------------- 

WITH ROW_NUM_CTE AS (
SELECT * ,ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
	ORDER BY	 UniqueID) Row_num
FROM ProjectPortfolio..NashvilleHousing 
)
SELECT *
FROM ROW_NUM_CTE
where Row_num > 1
order by PropertyAddress

-------------------------------------------------------------DELETION--------------------------------------------------------

WITH ROW_NUM_CTE AS (
SELECT * ,ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
	ORDER BY	 UniqueID) Row_num
FROM ProjectPortfolio..NashvilleHousing 
)
DELETE 
FROM ROW_NUM_CTE
where Row_num > 1

-------------------------------------------------------DELETE UNUSED COLUMNS-------------------------------------------------------

ALTER TABLE ProjectPortfolio..NashvilleHousing 
DROP COLUMN SaleDate,PropertyAddress,OwnerAddress,TaxDistrict
