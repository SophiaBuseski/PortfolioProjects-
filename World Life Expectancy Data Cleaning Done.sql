# World Life Expectancy Project (Data Cleaning) 

#downloading and uploading the data 
#initial exploration of data 
SELECT * 
FROM world_life_expectancy
;

#Identify any duplicates and remove them 
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1 
;

#Subquery to identify what row number the duplicates are 
SELECT * 
FROM ( 
    SELECT Row_ID, 
    CONCAT(Country, Year),
    ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
    FROM world_life_expectancy
    ) AS Row_Table
WHERE Row_Num > 1 
;

#actually removing the duplicates 
DELETE FROM world_life_expectancy
WHERE 
    Row_ID IN (
    SELECT Row_ID
FROM ( 
    SELECT Row_ID, 
    CONCAT(Country, Year),
    ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
    FROM world_life_expectancy
    ) AS Row_Table
WHERE Row_Num > 1 
)
;

#looking at the nulls or blanks 
SELECT * 
FROM world_life_expectancy
WHERE Status = ''
;

#seeing that the blanks should either have "developing" or "developed", there is no other option to choose from 
SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE Status <> ''
;

SELECT DISTINCT(Country) 
FROM world_life_expectancy
WHERE Status = 'Developing' ; 

#Easier to understand, but does not work due to data
#UPDATE world_life_expectancy
#SET STATUS = 'Developing'
#WHERE Country IN (SELECT DISTINCT(Country) 
            #FROM world_life_expectancy
            #WHERE Status = 'Developing'); 
            
            
 #Joining to itself, because the above gives errors due to data   joining to itself so that way we can filter based off other table 
 UPDATE world_life_expectancy table1
 JOIN world_life_expectancy table2 
    ON table1.Country = table2.Country
SET table1.Status = 'Developing'
WHERE table1.Status = ''
AND table2.Status <> ''
AND table2.Status = 'Developing' ; 

#Seeing that there are still blanks/nulls here 
SELECT * 
FROM world_life_expectancy
WHERE Country = 'United States of America'  
;

#Must do the same for developed 
UPDATE world_life_expectancy table1
 JOIN world_life_expectancy table2 
    ON table1.Country = table2.Country
SET table1.Status = 'Developed'
WHERE table1.Status = ''
AND table2.Status <> ''
AND table2.Status = 'Developed' ; 

#Double checking 
SELECT * 
FROM world_life_expectancy
WHERE Status IS NULL 
;
#No more blanks in status! 

#Now look for the blanks in life expetancy 
#use backtick marks (below tilde)
SELECT * 
FROM world_life_expectancy
WHERE `Life expectancy` = ''
;

#where there are blanks or nulls in the life expectancy column, we are going to average the two years around it to get a rough guess. 
#To do this we are joining the table to itself, offsetting the join by 1 each direction (so we have the surrounding years) and then inputting the average.
SELECT table1.Country, table1.Year, table1.`Life expectancy`,
table2.Country, table2.Year, table2.`Life expectancy`,
table3.Country, table3.Year, table3.`Life expectancy`,
ROUND((table2.`Life expectancy` + table3.`Life expectancy`)/2,1)
FROM world_life_expectancy table1 
JOIN world_life_expectancy table2
    ON table1.Country = table2.Country
    AND table1.Year = Table2.Year - 1
    JOIN world_life_expectancy table3
    ON table1.Country = table3.Country
    AND table1.Year = Table3.Year + 1
WHERE table1.`Life expectancy` = ''
;

#Actually setting/inserting the averages taken above as the new data in the blanks 
UPDATE world_life_expectancy table1 
JOIN world_life_expectancy table2
    ON table1.Country = table2.Country
    AND table1.Year = Table2.Year - 1
    JOIN world_life_expectancy table3
    ON table1.Country = table3.Country
    AND table1.Year = Table3.Year + 1
    SET table1.`Life expectancy` = ROUND((table2.`Life expectancy` + table3.`Life expectancy`)/2,1)
    WHERE table1.`Life expectancy` = ''
    ;
    
#Double checking that we didnt miss any
SELECT * 
FROM world_life_expectancy
#WHERE `Life expectancy` = ''
;

#Data has been cleaned :) (at least from what we can tell with just looking).alter

#Filtering out zeros and looking at the biggest differences in ages
SELECT Country, 
MIN(`Life expectancy`), 
MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1) AS Life_Increase_15_Years
FROM world_life_expectancy
GROUP BY Country 
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0 
ORDER BY Life_Increase_15_Years DESC
;

#Looking at the average year/average life expectancy per year 
SELECT Year, ROUND(AVG(`Life expectancy`),2)
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
AND `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year
;


SELECT * 
FROM world_life_expectancy
;

#Look to see if there is a correlation between the gdp and life expectancy
#in 2007 it was 67.5 then in 2022 it was 71.62 somewhere around 68 -- lower than 68 is lower than world average roughly 
SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp,ROUND(AVG(GDP),1) AS GDP 
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND GDP > 0
ORDER BY GDP DESC
;
#Noticing that the lower gdps have lower life expectancies, which makes sense due to infrastructure and the higher GDPS the higher the life expectancy 
#All just from glancing at the data.... now lets make sure 

#We can for sure make a visualization rn with tabelau and run this to see this graph! 

#Writing case statements 
SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END) High_GDP_Life_Expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) Low_GDP_Count,
AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END) Low_GDP_Life_Expectancy
FROM world_life_expectancy
;
#of the countries that have a gdp of over 1500(about the halfway point), their average life expectancy is 74.20
#of the countries with a low gdp, then the life expectancy is 64.70
#this shows a strong correlation with these two columns
#added null instead of zero to not mess with taking the average

SELECT Status,ROUND(AVG(`Life expectancy`),1)
FROM world_life_expectancy 
GROUP BY Status
; 
#developing the average life expectancy is 66.8, while developed is 79.2 -- this does not give a really clear picture because of how many countries are involved in each. 

SELECT Status, COUNT(DISTINCT Country), ROUND(AVG(`Life expectancy`),1)
FROM world_life_expectancy 
GROUP BY Status
; 
#the developed is 32 while developing is 161, which means the above is pretty skewed
#add on the averages part and then we get a bit of a better picture when looking at the data 

#want to look at the bmi and life expectancy to see if there is correlation/anything odd -- would say pretty high correlation of them 
SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Expectancy, ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy 
GROUP BY Country 
HAVING Life_Expectancy > 0 
AND BMI > 0 
ORDER BY BMI DESC
; 

#rolling total to see/compare country and adult mortality 
SELECT Country, Year, `Life expectancy`, `Adult Mortality`, 
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY YEAR) AS Rolling_Total
FROM world_life_expectancy
WHERE Country LIKE "%United%"
;
#Would love to see population and compare in this section in future. 

#the end 
