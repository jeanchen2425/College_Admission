-- Curators

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Admissions;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3 (
    CID INT NOT NULL,
    categoryName TEXT NOT NULL,
    PRIMARY KEY(CID, categoryName)
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.

DROP VIEW IF EXISTS FromHighSchool CASCADE;
DROP VIEW IF EXISTS FromCollege CASCADE;
DROP VIEW IF EXISTS Combine CASCADE;


-- Define views for your intermediate steps here:

-- Create a view that hypothesized if customer has bought and reviewd every item 
-- in all category
DROP VIEW IF EXISTS FromHighSchool CASCADE;
CREATE VIEW FromHighSchool AS
select ethnicity, CAST(admission as FLOAT)/ CAST(applied as FLOAT) as admission_rate , school from Freshmen group by school, ethnicity, admission_rate;


DROP VIEW IF EXISTS FromCollege CASCADE;
CREATE VIEW FromCollege AS
select ethnicity, CAST(admission as FLOAT)/ CAST(applied as FLOAT) as admission_rate , school from Transfers group by school, ethnicity, admission_rate;

DROP VIEW IF EXISTS Combine CASCADE;
CREATE VIEW Combine AS
select * from FromCollege
union all
select * from FromHighSchool;


-- Your query that answers the question goes below the "insert into" line:
insert into q3
select * from Combine; 