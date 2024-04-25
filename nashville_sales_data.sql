DROP TABLE Sales;

--Created table named Sales to import Nashville sales data
CREATE TABLE Sales (
	UniqueID	varchar(255),
	ParcelID	varchar(255),
	LandUse	varchar(255),
	PropertyAddress	varchar(255),
	SaleDate varchar(255),
	SalePrice varchar(255),
	LegalReference	varchar(255),
	SoldAsVacant	varchar(255),	
	OwnerName varchar(255),
	OwnerAddress varchar(255),	
	Acreage	varchar(255),
	TaxDistrict varchar(255),
	LandValue	varchar(255),
	BuildingValue	varchar(255),
	TotalValue	varchar(255),	
	YearBuilt	varchar(255),
	Bedrooms	varchar(255),
	FullBath	varchar(255),	
	HalfBath	varchar(255));

--Copied Nashville Sales Data
COPY Sales FROM '/Users/christopherbond/Copy of Nashville Housing Raw Data.csv' WITH (FORMAT csv);

--File Imported Columns Names...This Deleted That First Row
DELETE FROM Sales
WHERE UniqueID LIKE '%UniqueID%';

--Due to CSV file being all string formatted...changed dtype of all 
--columns where required
ALTER TABLE Sales
  alter column uniqueID type numeric
    using (trim(uniqueID)::numeric);

ALTER TABLE Sales
  alter column saledate type date
    using (trim(saledate)::date);

--Disocovered issue with commas in saleprice column
SELECT saleprice FROM Sales 
WHERE saleprice LIKE '%,%';

SELECT saleprice FROM Sales 
WHERE saleprice LIKE '%$%';
	
--Desired to remove the commas and $ to cast column as numeric
update Sales
   set saleprice = regexp_replace(saleprice, '[,]+','','g');
   
update Sales
   set saleprice = regexp_replace(saleprice, '[$]+','','g');
   
--Confirmed all had been removed from saleprice column.
SELECT saleprice FROM Sales 
WHERE saleprice LIKE '%,%';

SELECT saleprice FROM Sales 
WHERE saleprice LIKE '%$%';
   
ALTER TABLE Sales
  alter column saleprice type numeric
    using (trim(saleprice)::numeric);
	
ALTER TABLE Sales
  alter column acreage type numeric
    using (trim(acreage)::numeric);
	
ALTER TABLE Sales
  alter column landvalue type numeric
    using (trim(landvalue)::numeric);
	
ALTER TABLE Sales
  alter column buildingvalue type numeric
    using (trim(buildingvalue)::numeric);
	
ALTER TABLE Sales
  alter column totalvalue type numeric
    using (trim(totalvalue)::numeric);
	
ALTER TABLE Sales
  alter column yearbuilt type numeric
    using (trim(yearbuilt)::numeric);
	
ALTER TABLE Sales
  alter column bedrooms type numeric
    using (trim(bedrooms)::numeric);
	
ALTER TABLE Sales
  alter column fullbath type numeric
    using (trim(fullbath)::numeric);
	
ALTER TABLE Sales
  alter column halfbath type numeric
    using (trim(halfbath)::numeric);
	   
--Wished to break down property address into property_street 
-- and property_city columns...these columns needed to be added.
ALTER TABLE Sales ADD property_street VARCHAR(255),
	ADD property_city VARCHAR(255);
	
--Updated table by splitting property address into 
-- street and city
UPDATE Sales
SET property_street = SPLIT_PART(propertyaddress, ',', 1),
	property_city = SPLIT_PART(propertyaddress, ',', 2);
	
--Dropped property address column. 
alter table Sales drop column propertyaddress;

--Wished to break down owner address into owner_street 
-- owner_city, and owner_state columns...these columns needed to be added.
ALTER TABLE Sales ADD owner_street VARCHAR(255),
	ADD owner_city VARCHAR(255),
	ADD owner_state VARCHAR(255);
	
--Updated table by splitting property address into 
-- street and city
UPDATE Sales
SET owner_street = SPLIT_PART(owneraddress, ',', 1),
	owner_city = SPLIT_PART(owneraddress, ',', 2),
	owner_state = SPLIT_PART(owneraddress, ',', 3);
	
--Dropped property address column. 
alter table Sales drop column owneraddress;

--Noticed an N in SoldAsVacantColumn. Ran the following to see
--how frequent the issue. 
SELECT DISTINCT(SoldAsVacant), COUNT (SoldAsVacant)
FROM Sales
GROUP BY SoldAsVacant
ORDER BY 2;

--Updated column to rectify the issue
UPDATE Sales SET SoldAsVacant  = 'Yes' WHERE SoldAsVacant = 'Y';
UPDATE Sales SET SoldAsVacant  = 'No' WHERE SoldAsVacant = 'N';

--Confirmed change took place. 
SELECT DISTINCT(SoldAsVacant), COUNT (SoldAsVacant)
FROM Sales
GROUP BY SoldAsVacant
ORDER BY 2;

--Create column for formatted saledates in MM-DD-YYYY format
ALTER TABLE Sales ADD formatted_saledate text;

--Converted dates and added to formatted saledates column
UPDATE Sales SET formatted_saledate = to_char(saledate,'MM-DD-YYYY');

--Dropped orginal saledate column
ALTER TABLE Sales
DROP COLUMN saledate;

--Changed formatted column name to salesdate
ALTER TABLE Sales
  RENAME COLUMN formatted_saledate TO salesdate;

--Added sale month column
ALTER TABLE Sales ADD sale_month text;

--Copied extracted from saledate column
UPDATE Sales
SET sale_month = SPLIT_PART(salesdate, '-', 1);

--Explored average sale price/month and total sales/month.
SELECT sale_month, COUNT(sale_month),ROUND(AVG(saleprice),2)
FROM Sales
GROUP BY sale_month
ORDER BY AVG(saleprice) DESC;

--Deleted all rows containing null values to prepare for machine learning
--Would typically attempt to process somehow but numerous rows
--are missing all numerical home information 
SELECT * FROM sales
WHERE buildingvalue IS null;
--Saved this file

SELECT * FROM Sales;











