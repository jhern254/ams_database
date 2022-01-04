-- Temp table for pers screen test 
CREATE TABLE pers_temp (
    eid integer,
    first_name varchar(255),
    last_name varchar,
    birthday varchar(255),
    hire_date date,
    next_review_date date,
    fte numeric(5,2),   
    salary_hourly numeric(10, 2),
    pt_created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);
-- psql insert
\copy pers_temp (eid, first_name, last_name, birthday, hire_date, 
next_review_date, fte, salary_hourly)
FROM /tmp/pers_sample.csv WITH (FORMAT CSV, HEADER, NULL 'NA', encoding 'windows-1251')



-----------------------------------------------------------------------------
-----------------------------------------------------------------------------




