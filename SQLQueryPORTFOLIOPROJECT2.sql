--DATA CLEANING

select*
from housing

--standardizing date format
select SaleDate
from housing
 
 Update housing
 set saledate = convert(date, saledate)

 alter table housing
 alter column saledate date
 go

--Property address with missing data
--from the data notice that properties with the same ParcelID have the same property address
--we shall therefore use the parcelID to fill in the missing addresses, the uniqueID cannot repeat itself
select *
from housing
where propertyaddress is null
order by ParcelID

select A.parcelid, A.propertyaddress,B.parcelid,B.propertyaddress, isnull(A.propertyaddress, B.propertyaddress)
from housing A
join housing B
on A.parcelid = B.parcelid
and A.[UniqueID ] <> B.[UniqueID ]
where A.propertyaddress is null

update A
set propertyaddress = isnull(A.propertyaddress, B.propertyaddress)
from housing A
join housing B
on A.parcelid = B.parcelid
and A.[UniqueID ] <> B.[UniqueID ]
where A.propertyaddress is null

--Breaking down address into individual columns (Address, City, state)
select Propertyaddress
from housing

select 
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address,
 substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as Address
from housing

alter table housing
add propertysplitaddress nvarchar(255)

update housing
set propertysplitaddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) 


alter table housing
add propertysplitcity nvarchar(255)

update housing
set propertysplitcity = substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))

select*
from housing




--owner address

select owneraddress
from housing

select PARSENAME(replace(owneraddress, ',', '.'),3),
PARSENAME(replace(owneraddress, ',', '.'),2),
PARSENAME(replace(owneraddress, ',', '.'),1)
from housing

alter table housing
add ownersplitaddress nvarchar(255)

alter table housing
add ownersplitcity nvarchar(255)

alter table housing
add ownersplitstate nvarchar(255)

update housing
set ownersplitaddress = PARSENAME(replace(owneraddress, ',', '.'),3)

update housing
set ownersplitcity = PARSENAME(replace(owneraddress, ',', '.'),2)

update housing
set ownersplitstate = PARSENAME(replace(owneraddress, ',', '.'),1)



--change Y and N to yes and no in "sold as vacant" field

select distinct (soldasvacant), count(soldasvacant)
from housing
group by soldasvacant

select soldasvacant,
case when soldasvacant = 'y' then 'yes'
     when soldasvacant = 'n' then 'no'
	 else soldasvacant
	 end
from housing

update housing
set soldasvacant = case when soldasvacant = 'y' then 'yes'
     when soldasvacant = 'n' then 'no'
	 else soldasvacant
	 end


--Removing duplicates
with RownumCTE as (
select*,
   row_number() over(partition by parcelid, propertyaddress, saleprice, saledate, legalreference order by uniqueid) row_num
from housing
)

delete
from RownumCTE
where row_num>1

--DELETING UNUSED COLUMNS
select*
from housing

alter table housing
drop column owneraddress, taxdistrict, propertyaddress



