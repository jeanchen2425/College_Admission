-- Helpfulness

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Admissions;
DROP TABLE IF EXISTS q2 CASCADE;

create table q2(
    school TEXT,
    admission_rate FLOAT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;


-- Define views for your intermediate steps here:

DROP view IF EXISTS rates CASCADE;
CREATE view rates as 
select school, ROUND(CAST(admission as FLOAT)/ CAST(applied as FLOAT),2) as admission_rate 
from Freshmen where applied > 500 order by admission_rate desc;

-- Your query that answers the question goes below the "insert into" line:
insert into q2
rates;