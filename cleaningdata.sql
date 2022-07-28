--CLEANING DATA

select * 
from portfolioproject..nashvillehousing

alter table portfolioproject..nashvillehousing
add SaleDateConverted date;

update portfolioproject..nashvillehousing
set SaleDateConverted = convert(date,SaleDate)\

-- can delete old sale date and rename and use new one 


--updating null values in property address that have the same address as other properties like apartments
select *
from portfolioproject..nashvillehousing
where PropertyAddress is null
order by ParcelID

 select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
 from portfolioproject..nashvillehousing as a
 join portfolioproject..nashvillehousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

	update a
	set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
	from portfolioproject..nashvillehousing as a
 join portfolioproject..nashvillehousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]


	--breaking address into individual columns (Address,City,State)

	select PropertyAddress
	from portfolioproject..nashvillehousing
	
	select
	substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1 )as address
	substring (PropertyAddress, charindex(',',PropertyAddress)+ 1, len(PropertyAddress)) as Address
from portfolioproject..nashvillehousing

alter table portfolioproject..nashvillehousing
add PropertySplitAddress nvarchar(255);

update portfolioproject..nashvillehousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1)

alter table portfolioproject..nashvillehousing
add PropertySplitCity nvarchar(255);

update portfolioproject..nashvillehousing
set PropertySplitCity = substring (PropertyAddress, charindex(',',PropertyAddress)+ 1, len(PropertyAddress))


select *
from portfolioproject..nashvillehousing


--changing owner address
select OwnerAddress
from portfolioproject..nashvillehousing
where OwnerAddress is not null

select 
parsename(replace(OwnerAddress, ',','.') , 3) as Address,
parsename(replace(OwnerAddress, ',','.') , 2) as City,
parsename(replace(OwnerAddress, ',','.') , 1) as State
from portfolioproject..nashvillehousing
where OwnerAddress is not null

alter table portfolioproject..nashvillehousing
add OwnerSplitAddress nvarchar(255);

alter table portfolioproject..nashvillehousing
ADD OwnerSplitCity nvarchar(255);

alter table portfolioproject..nashvillehousing
add OwnerSplitState nvarchar(255);

update portfolioproject..nashvillehousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',','.') , 3);

update portfolioproject..nashvillehousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',','.') , 2);

update portfolioproject..nashvillehousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',','.') , 1);

--Changing y and n to yes and no in sold as vacant

select distinct(SoldAsVacant), count(SoldAsVacant)
from portfolioproject..nashvillehousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from portfolioproject..nashvillehousing

update portfolioproject..nashvillehousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end


--removing Duplicates
with RowNumCTE as(
select *, 
	row_number() over (
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by UniqueID)
				as row_num
from portfolioproject..nashvillehousing

)

delete
from RowNumCTE
where row_num > 1

select *
from RowNumCTE
where row_num > 1

--deleting unused columns

alter table portfolioproject..nashvillehousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

select *
from portfolioproject..nashvillehousing

