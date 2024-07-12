
-- **************************************************       DATA  WRANGLING      ****************************************************
-- In this project we're going to clean the data and make it ready for further analysis


SELECT * FROM old_cars_data;	-- taking a view at the data and familarizing ourselves with it

CREATE TABLE cars				-- Creating a duplicate table for back-up
LIKE old_cars_data;

INSERT cars						-- Inserting values into a duplicate table
SELECT *
FROM old_cars_data;

SELECT * FROM cars;  			-- Now we can mess with the duplicate table


-- ***************************************************      FINDING DUPLICATES    *********************************************************
-- Our table doesn't have any unique row identifier, so we'll use a SUBQUERY and PARTITION BY each row

SELECT *
FROM (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY symboling, normalized_losses, make, fuel_type, body_style, drive_wheels, engine_location, length, height, curb_weight,
			 engine_type, num_of_cylinders, engine_size, fuel_system, bore, stroke, compression_ratio, horsepower, peak_rpm, city_mpg,
             highway_mpg, `price;;;;;;;;;;;;;;;;;;;;;price` ) AS unique_rows
FROM cars) AS new_rows
WHERE unique_rows > 1; 		-- It appears we have no duplicate data



-- **********************************************   MISSING DATA (NULL VALUES)      *************************************************

-- The missing values in our data are represented by '?', we'll go through each column to try and identify any '?'s
-- N.B: This query will not run, it's just a demo that I checked through all the columns
SELECT *				
FROM cars
WHERE all_columns LIKE '%?%'; 
-- There are a total of 45 ?s in the dataset, 39 in normalized_losses, 2 num_of_doors, 4 price, so let's deal with them

SELECT round(avg(normalized_losses), 0)			-- calclulating the average value in normalized_losses
FROM cars
where normalized_losses <> '?';

UPDATE cars							-- Replacing ?s with the average value calculated above
SET normalized_losses = 121
WHERE normalized_losses = '?';


-- Replacing empty values in with the most frequent values
SELECT num_of_doors, count(*)
FROM cars
GROUP BY num_of_doors;		-- 4 door car appeared the most frequent, so we'll replace the missing values with 4 doors

UPDATE cars
SET num_of_doors = 'four'
WHERE num_of_doors LIKE '%?%';


-- Deleting rows where price has no value
DELETE FROM cars
WHERE `price;;;;;;;;;;;;;;;;;;;;;price` LIKE '%?%';


-- *****************************************************    DATA TRANSFORMATION      ****************************************************
-- In this section, we'll transform the data into a more readable format


-- Renaming the columns
ALTER TABLE cars		
RENAME COLUMN `price;;;;;;;;;;;;;;;;;;;;;price` TO price;

ALTER TABLE cars
RENAME COLUMN symboling TO risk_level;		-- -3 means safer whereas +3 means more riskier


-- removing the trailing ';' in the price column
UPDATE cars
SET price =  trim(';' FROM price);

DESCRIBE cars;			-- Checking the description

ALTER TABLE cars			-- Changing the data types
MODIFY COLUMN price INT;

ALTER TABLE cars
MODIFY COLUMN normalized_losses INT;


-- ************************************************    DATA STANDARDIZATION      *************************************************************
-- Getting the data into a correct standard

-- Changing data types
ALTER TABLE cars
MODIFY COLUMN highway_mpg DOUBLE;

ALTER TABLE cars
MODIFY COLUMN city_mpg DOUBLE;

-- Transforming the values from [mpg to l/100KM]
UPDATE cars
SET highway_mpg = round(235.2145/highway_mpg, 1);

UPDATE cars
SET city_mpg = round(235.2145/city_mpg, 1);


-- ************************************************    BINNING      *************************************************************
-- Here we'll be grouping large numerical values into groups for better readability for further analysis

-- Binning the horsepower values into groups with the difference of 20

ALTER TABLE cars					-- changing the data type first
MODIFY COLUMN horsepower TEXT;

UPDATE cars							-- updating the table
SET horsepower = 
				CASE
					WHEN horsepower <= 50 THEN 'Low'
					WHEN horsepower <= 100 THEN 'Medium'
					WHEN horsepower <= 150 THEN 'High'
					ELSE 'Very high'
				END;

select * from cars;				-- Now our table is clean and ready for exploration !!



-- *****************  END   ************  END   ************  END   ************  END   ************  END   ************  END   ************  END   ************
