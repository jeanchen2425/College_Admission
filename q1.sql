-- Helpfulness

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Admissions;
DROP TABLE IF EXISTS q1 CASCADE;

create table q1(
    county TEXT,
    city TEXT,
    Highschool_admission double precision,
    transfer_admission double precision,
    higher TEXT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;


-- Define views for your intermediate steps here:

-- Group by (school, county, city), find the average admission and applied across years and campus (find the general admission info about the school).
DROP VIEW IF EXISTS Freshmen_group CASCADE;
CREATE VIEW Freshmen_group AS
SELECT Freshmen.school, county, city, avg(CAST(applied as numeric)) as applied, avg(CAST(admission as numeric)) as admission
FROM Freshmen JOIN HighschoolInfo ON Freshmen.school = HighschoolInfo.school
WHERE admission is not NULL
GROUP BY (Freshmen.school, county, city);

DROP VIEW IF EXISTS Transfers_group CASCADE;
CREATE VIEW Transfers_group AS
SELECT Transfers.school, county, city, avg(CAST(applied as numeric)) as applied, avg(CAST(admission as numeric)) as admission
FROM Transfers JOIN SchoolInfo ON Transfers.school = SchoolInfo.school
WHERE admission is not NULL
GROUP BY (Transfers.school, county, city);

-- Create a new column admission rate
DROP VIEW IF EXISTS FreshmenRate CASCADE;
CREATE VIEW FreshmenRate as 
SELECT school, county, city, CAST(admission as FLOAT)/ CAST(applied as FLOAT) as admission_rate
from Freshmen_group;

DROP VIEW IF EXISTS TransferRate CASCADE;
CREATE VIEW TransferRate as 
SELECT school, county, city, CAST(admission as FLOAT)/ CAST(applied as FLOAT) as admission_rate
from Transfers_group;

-- Group by (County, City), get the average admission rate of 1) highschool and 2) college
DROP VIEW IF EXISTS HighschoolRegionRate CASCADE;
CREATE VIEW HighschoolRegionRate as 
SELECT county, city, avg(admission_rate) AS Highschool_admission
from FreshmenRate
group by (county, city);

DROP VIEW IF EXISTS CollegeRegionRate CASCADE;
CREATE VIEW CollegeRegionRate as 
SELECT county, city, avg(admission_rate) AS Transfer_admission
from TransferRate
group by (county, city);

-- Combine the highschool admission rate and transfer admission based on county, city
DROP VIEW IF EXISTS Combined CASCADE;
CREATE VIEW Combined as 
SELECT HighschoolRegionRate.county, HighschoolRegionRate.city, Highschool_admission, Transfer_admission
FROM HighschoolRegionRate JOIN CollegeRegionRate ON HighschoolRegionRate.county = CollegeRegionRate.county and HighschoolRegionRate.city = CollegeRegionRate.city
WHERE HighschoolRegionRate.city is not NULL and CollegeRegionRate.city is not NULL; 

-- For each (county, city), who has a higher general admission rate? 
DROP VIEW IF EXISTS CombinedCondition CASCADE;
CREATE VIEW CombinedCondition AS 
SELECT county, city, Highschool_admission, Transfer_admission,
    CASE WHEN (Highschool_admission > Transfer_admission) THEN 'Highschool'
    else 'COLLEGE'
    END AS Higher
FROM Combined;



-- Your query that answers the question goes below the "insert into" line:
insert into q1
select * from CombinedCondition; 