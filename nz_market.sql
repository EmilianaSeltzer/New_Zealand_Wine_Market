USE nz_wine_market;
DROP TABLE wine_variety;

#I'll start creating the tables:

CREATE TABLE variety (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Variety VARCHAR(255),
    Colour VARCHAR(10),
    Year INT,
    Hectare VARCHAR(50)
);
SET GLOBAL local_infile = 1;
SELECT 
    *
FROM
    variety;

CREATE TABLE nz_regions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Region VARCHAR(255),
    Year INT,
    Regional_area_producing_ha INT,
    Number_of_vineyards INT
);

CREATE TABLE wine_export (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Year_ended_June INT,
    Series VARCHAR(50),
    Sector VARCHAR(100),
    Subsector VARCHAR(100),
    Measure VARCHAR(100),
    Value FLOAT,
    Value_Unit VARCHAR(100),
    Value_Label VARCHAR(255),
    Null_Reason VARCHAR(255),
    Metadata_1 VARCHAR(255),
    Metadata_2 VARCHAR(255)
);

#I've imported the data with Table Data Import Wizard, some adjustments were made in Python to fix format

SELECT *
FROM nz_regions;

SELECT *
FROM variety;

SELECT *
FROM wine_export;

# Now, we have the data imported, I'll start exploring the dataset

# ***Exploratory Analysis***

SELECT COUNT(*) AS Total_Registros FROM nz_regions;
SELECT COUNT(*) AS Total_Registros FROM variety;
SELECT COUNT(*) AS Total_Registros FROM wine_export;

#There are 10 rows at nz_regions, 406 rows in variety, and 1975 rows in wine_export table

SELECT * FROM wine_export
LIMIT 10;

#Wine Export from New Zealand from year 2004 to 2024, plus forecust to year 2028.

SELECT * FROM wine_export
WHERE Subsector="Wine"
LIMIT 10;

SELECT * FROM wine_export
WHERE Subsector="Wine"
ORDER BY Value DESC
;
#The Year 2028 forecast is optimistic with 328000 thousand liters of wine exportation

SELECT * FROM wine_export
WHERE Subsector="Wine" AND Year_ended_June <2024
ORDER BY Value DESC;
#Until now, the year 2023 has the top export volume in thousand litres with 314877.

# *** Descriptive Analysis***

SELECT
	avg(Regional_area_producing_ha) AS Average_hectares,
    sum(Regional_area_producing_ha) AS Total_hectares,
    max(Regional_area_producing_ha) AS Max_hectares,
    min(Regional_area_producing_ha) AS Min_hectares
FROM nz_regions; 
#The average is 3954.2 hectares, suming a Total of 39542, the biggest hectare is 27818 and the smallest one is 19.

SELECT DISTINCT Variety
FROM variety;
#All varieties produced in New Zealand.

SELECT DISTINCT Variety
FROM variety
WHERE Colour= "Red"
ORDER BY Variety;
#Just red wine varieties of grapes used in wine production.

SELECT DISTINCT Variety
FROM variety
WHERE Colour= "White"
ORDER BY Variety;
#Just white wine grapes variety used in wine production.

SELECT *
FROM variety
WHERE Variety LIKE "%Sauv%" AND Hectare >=5000;
#Varieties of Sauvignon most popular produced in NZ.

SELECT *
FROM variety
WHERE Colour LIKE "%R%" AND Hectare >=5000;
#Most popular Red wine produced in NZ.

SELECT *
FROM variety
WHERE Colour LIKE "%W%" AND Hectare >=5000;
#Most popular White wine produced in NZ.

SELECT *
FROM variety
ORDER BY Hectare ASC;
#Top 5 most produced variety >> I noticed the order is wrong, and is because Hectare is in VARCHAR format instead a numeric one. I'll update:

DESCRIBE variety;
ALTER TABLE variety
MODIFY COLUMN Hectare INT;

SELECT *
FROM variety
ORDER BY Hectare ASC;
#Now the issue was fixed, we can continue with the analysis.

SELECT *
FROM variety
ORDER BY Hectare ASC;

SELECT Colour, COUNT(DISTINCT Variety) AS Grape_colour_quantity
FROM variety
GROUP BY Colour;
#How many types of red/white grapes varieties are produced in NZ.

SELECT *
FROM Variety
WHERE Year >= 2023
ORDER BY Hectare DESC;
#Last years production order by Hectare.

SELECT variety, avg(hectare) AS Sauvignon_Blanc_Avg
FROM Variety
WHERE Variety LIKE "%Sauvignon Blanc%"
GROUP BY variety ;
#Sauvignon Blanc ha average

SELECT variety, avg(hectare) AS Pinot_Noir_Avg
FROM Variety
WHERE Variety LIKE "%Pinot N%"
GROUP BY variety ;
#Pinot Noir ha average

SELECT variety, avg(hectare) AS Pinot_Gris_Avg
FROM Variety
WHERE Variety LIKE "%Pinot g%"
GROUP BY variety ;
#Pinot Gris ha average

SELECT variety, avg(hectare) AS Chardonnay_Avg
FROM Variety
WHERE Variety LIKE "%Chardonnay%"
GROUP BY variety ;
#Chardonnay ha average

SELECT variety, avg(hectare) AS Merlot_Avg
FROM Variety
WHERE Variety LIKE "%Merlot%"
GROUP BY variety ;
#Merlot ha average

SELECT *
FROM wine_export
WHERE Series="Actual" AND Subsector="Wine"
ORDER BY Year_ended_June ASC;
#List of historical data of wine export 

# ***Temporal Analysis***

SELECT Year, SUM(Hectare) AS Total_Hectare_Production
FROM variety
GROUP BY Year
ORDER BY Year;
#Total production per year

SELECT Year, SUM(Hectare) AS Total_RED_Hectare_Production
FROM variety
WHERE Colour ="Red"
GROUP BY Year
ORDER BY Year;
#Total production per year of red grapes variety

SELECT Year, SUM(Hectare) AS Total_WHITE_Hectare_Production
FROM variety
WHERE Colour ="white"
GROUP BY Year
ORDER BY Year;
#Total production per year of white grapes variety

SELECT Year_ended_June, SUM(value) AS Year_Export
FROM wine_export
WHERE Subsector="wine"
GROUP BY Year_ended_June
ORDER BY Year_ended_June;
#Total exports per year including forecast

SELECT *
FROM nz_regions
ORDER BY Number_of_vineyards DESC
LIMIT 3;
#Top 3 regions with most amount of vineyards

SELECT *
FROM nz_regions
ORDER BY Regional_area_producing_ha DESC
LIMIT 3;
#Top 3 regions with most amount of ha

#Before continuing exploring, I want to remove a few columns in the wine export table and rename columns.

ALTER TABLE wine_export
DROP COLUMN Null_Reason,
DROP COLUMN Metadata_1,
DROP COLUMN Metadata_2;

ALTER TABLE wine_export
CHANGE COLUMN Year_ended_June Year INT;

SELECT *
FROM wine_export
LIMIT 5;

# ***New Zealand exports analysis***

SELECT DISTINCT Sector
FROM wine_export
ORDER BY Sector;
#New Zealand sectors that export overseas

SELECT DISTINCT subsector, sector
FROM wine_export
ORDER BY Sector;
#New Zealand subsectors that export overseas

SELECT Sector, ROUND(AVG(DISTINCT Value),2) AS Avg_Value_per_sector
FROM wine_export
GROUP BY Sector
ORDER BY Avg_Value_per_sector DESC;
#New Zealand sectors that export overseas order by value

SELECT Subsector, ROUND(AVG(DISTINCT Value),2) AS Avg_Value_per_subsector
FROM wine_export
GROUP BY Subsector
ORDER BY Avg_Value_per_subsector DESC;
#New Zealand subsectors that export overseas order by value

SELECT DISTINCT Measure
FROM wine_export;
#Metrics availables to analyse exports

SELECT Year, round(SUM(Value),2) as Export_total_VOLUME
FROM wine_export
WHERE Measure = "Export volume"
GROUP BY Year
ORDER BY YEAR ASC;
#Total volume exported by year

SELECT Year, round(SUM(Value),2) as Export_total_Avg_price
FROM wine_export
WHERE Measure = "Average export price"
GROUP BY Year
ORDER BY YEAR ASC;
#AVG price exported by year

SELECT Year, round(SUM(Value),2) as Export_total_Revenue
FROM wine_export
WHERE Measure = "Export revenue"
GROUP BY Year
ORDER BY YEAR ASC;
#Revenue generated by exports per year

SELECT Year, round(SUM(Value),2) as Export_total_Revenue
FROM wine_export
WHERE Measure = "Export revenue" AND Subsector ="wine"
GROUP BY Year
ORDER BY YEAR ASC;
#Revenue generated by exports per year just by wine

SELECT subsector, round(SUM(Value),2) as Subsector_Revenue
FROM wine_export
WHERE Measure = "Export revenue"
GROUP BY subsector
ORDER BY Subsector_Revenue DESC;
#Revenue generated by subsector

# *** Compare export volume and income in the same year:***
SELECT a.Year, a.Total_Export_Volume, b.Total_Export_Revenue
FROM 
    (SELECT Year, ROUND(SUM(Value),2) AS Total_Export_Volume
     FROM wine_export
     WHERE Measure = 'Export volume'
     GROUP BY Year) a
JOIN 
    (SELECT Year, ROUND(SUM(Value),2) AS Total_Export_Revenue
     FROM wine_export
     WHERE Measure = 'Export revenue'
     GROUP BY Year) b
ON a.Year= b.Year
ORDER BY a.Year;

# *** Evolution of average price per year for wine:***
SELECT Year, Value AS Average_Export_Price
FROM wine_export
WHERE Measure = "Average export price" AND subsector = "wine"
order BY Year;

#***Wine variety per region and per year:

SELECT
v.id as variety_id,
v.Variety,
v.Colour,
v.Year,
v.Hectare,
r.id as region_id,
r.Region,
r.Regional_area_producing_ha,
r.Number_of_vineyards
FROM variety V
LEFT JOIN nz_regions r
ON v.Year = r.Year;

#***Exports data:***
SELECT DISTINCT *
FROM wine_export;

#***Wine exports from New Zealand , combinig the other tables:***
SELECT 
    v.id AS variety_id,
    v.Variety,
    v.Colour,
    v.Year,
    v.Hectare,
    r.id AS region_id,
    r.Region,
    r.Regional_area_producing_ha,
    r.Number_of_vineyards,
    e.id AS export_id,
    e.Year,
    e.Series,
    e.Sector,
    e.Subsector,
    e.Measure,
    e.Value,
    e.Value_Unit,
    e.Value_Label
FROM variety v
LEFT JOIN nz_regions r
ON v.Year = r.Year
LEFT JOIN wine_export e
ON v.Year = e.Year
WHERE Series = "Actual" AND Subsector = "Wine";

#***Wine exports from New Zealand , combinig variety table, just Export revenue order by Desc:***
SELECT 
    v.id AS variety_id,
    v.Variety,
    v.Colour,
    v.Year,
    v.Hectare,
    e.id AS export_id,
    e.Year,
    e.Series,
    e.Sector,
    e.Subsector,
    e.Measure,
    e.Value,
    e.Value_Unit,
    e.Value_Label
FROM variety v
LEFT JOIN wine_export e ON v.Year = e.Year
WHERE Series = "Actual" AND Subsector = "Wine" AND Measure = "Export revenue"
ORDER BY Value DESC;

#***Analysis of the most popular wine varieties:***
# Sauvignon Blanc
SELECT 
    v.Variety,
    v.Colour,
    v.Year,
    SUM(v.Hectare) AS Total_Hectare,
    r.Region,
    SUM(r.Regional_area_producing_ha) AS Total_Regional_Area_Producing,
    SUM(r.Number_of_vineyards) AS Total_Vineyards,
    SUM(e.Value) AS Total_Export_Value,
    e.Value_Unit,
    e.Measure
FROM variety v
LEFT JOIN nz_regions r
ON v.Year = r.Year
LEFT JOIN wine_export e
ON v.Year = e.Year
WHERE v.Variety = 'Sauvignon Blanc' -- Example with variety
GROUP BY v.Variety, v.Colour, v.Year, r.Region, e.Value_Unit, e.Measure;

# Chardonnay 
SELECT 
    v.Variety,
    v.Colour,
    v.Year,
    SUM(v.Hectare) AS Total_Hectare,
    r.Region,
    SUM(r.Regional_area_producing_ha) AS Total_Regional_Area_Producing,
    SUM(r.Number_of_vineyards) AS Total_Vineyards,
    SUM(e.Value) AS Total_Export_Value,
    e.Value_Unit,
    e.Measure
FROM variety v
LEFT JOIN nz_regions r
ON v.Year = r.Year
LEFT JOIN wine_export e
ON v.Year = e.Year
WHERE v.Variety = 'Chardonnay' -- Example with variety
GROUP BY v.Variety, v.Colour, v.Year, r.Region, e.Value_Unit, e.Measure;

# Pinot Gris
SELECT 
    v.Variety,
    v.Colour,
    v.Year,
    SUM(v.Hectare) AS Total_Hectare,
    r.Region,
    SUM(r.Regional_area_producing_ha) AS Total_Regional_Area_Producing,
    SUM(r.Number_of_vineyards) AS Total_Vineyards,
    SUM(e.Value) AS Total_Export_Value,
    e.Value_Unit,
    e.Measure
FROM variety v
LEFT JOIN nz_regions r
ON v.Year = r.Year
LEFT JOIN wine_export e
ON v.Year = e.Year
WHERE v.Variety = 'Pinot Gris' -- Example with variety
GROUP BY v.Variety, v.Colour, v.Year, r.Region, e.Value_Unit, e.Measure;
