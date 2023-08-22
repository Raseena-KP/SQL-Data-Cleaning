/*

Cleaning data in SQL Queries

*/
select *
from portfolio.dbo.NashvilleHousing$
-------------------------------------------------------------------------------------
--Standardize Date Format
select SaleDate,convert(Date,SaleDate)
from portfolio.dbo.NashvilleHousing$

update portfolio.dbo.NashvilleHousing$
set SaleDate=convert(Date,SaleDate)

alter table NashvilleHousing$
add SaleDateConverted Date;

update portfolio.dbo.NashvilleHousing$
set SaleDateConverted=convert(Date,SaleDate)

-------------------------------------------------------------------------------------
--Populate Property address
select *
from portfolio.dbo.NashvilleHousing$
where PropertyAddress is null

select *
from portfolio.dbo.NashvilleHousing$
order by ParcelID

select *
from portfolio.dbo.NashvilleHousing$
where PropertyAddress is null

select PropertyAddress
from portfolio.dbo.NashvilleHousing$
where ParcelID= '042 13 0 075.00'

select PropertyAddress
from portfolio.dbo.NashvilleHousing$
where ParcelID in (select ParcelID
from portfolio.dbo.NashvilleHousing$
where PropertyAddress is null)

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolio.dbo.NashvilleHousing$ as a
join portfolio.dbo.NashvilleHousing$ as b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolio.dbo.NashvilleHousing$ as a
join portfolio.dbo.NashvilleHousing$ as b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null
-------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns(Address, City,State)
select PropertyAddress
from NashvilleHousing$

select PropertyAddress,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as State
from NashvilleHousing$

alter table NashvilleHousing$
add PropertySplitAddress nvarchar(500), PropertySplitStaten varchar(500);

update NashvilleHousing$
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
	PropertySplitStaten=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

select * 
from NashvilleHousing$


select OwnerAddress,PARSENAME(REPLACE(OwnerAddress,',','.'),3) --parse name deal with period ,seperator ., so need to replace , with .
from NashvilleHousing$

alter table NashvilleHousing$
add OwnerSplitAddress nvarchar(255),
	OwnerSplitCity nvarchar(255),
	OwnerSplitSate nvarchar(255)


update NashvilleHousing$
set OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerSplitSate=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-------------------------------------------------------------------------------------
--change Y and N to Yes and NO in "Sold as vacant"
select distinct SoldAsVacant 
from NashvilleHousing$

select SoldAsVacant,COUNT(SoldAsVacant)
from NashvilleHousing$
group by SoldAsVacant

select SoldAsVacant,
case 
	when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
end as SoldAsVacant_updated
from NashvilleHousing$

update NashvilleHousing$
set SoldAsVacant= 
case 
	when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
end
-------------------------------------------------------------------------------------
--Remove Duplicates
--not a standard practice to delete data from the database
--write CTE and then write a windows function to find where there are duplicate values

--identify the duplicate rows using Row_number() and delete them
with RowNumCTE as(
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				PropertyAddress,SalePrice,
				SaleDate,
				LegalReference
				order by
					uniqueID
					) as row_num
from NashvilleHousing$
)

delete 
from RowNumCTE
where row_num>1


select *
from RowNumCTE
where row_num>1
order by PropertyAddress

select *
from NashvilleHousing$
-------------------------------------------------------------------------------------
--delete unused columns

alter table NashvilleHousing$
drop column PropertyAddress,OwnerAddress,TaxDistrict

alter table NashvilleHousing$
drop column SaleDate
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------