
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- PFR staging table - Ton of bad data failing constraints. Can't do much.
CREATE TABLE staging_pfr (
    project_id integer UNIQUE NOT NULL,   
    contract_number varchar(255), --UNIQUE   -- TODO: Have to edit this in db. Can have NULLS. Also, Idk. 1 non-unique. 
    fund_code smallint,                 -- need list of options. Add check later
    last_name varchar, 
    first_name varchar(255),    -- NEED EID
    department varchar,
    division varchar,
    subdivision varchar,
    proj_sponsor varchar,
    proj_title varchar,
    award_number varchar(255),  --UNIQUE. Same problem. Bad data entry. CHECKED: Not unique at all and has lots of NULLs
    proj_type varchar(255), --NOT NULL   -- TODO: Bad data entry. 1 NULL. Change for now to NULL
    fringe_rate numeric(5, 2),
    irb varchar(255),    --UNIQUE -- TODO: Not unique. Change in tables.
    iacuc varchar(255),  --UNIQUE -- TODO: Not unique. Change in tables.
    proj_start_date date,
    proj_end_date date,
    award_end_date date,
    proj_status varchar(255) NOT NULL,
    total_revenue numeric(15, 2),
    proj_budget numeric(15, 2) NOT NULL CHECK (proj_budget >= 0),
    proj_transfer_total numeric(15, 2),
    proj_total_cost numeric(15, 2) NOT NULL, --CHECK (proj_total_cost >= 0),  -- Fails. Idk, but 1 neg cost.
    proj_balance numeric(15, 2) NOT NULL,
    proj_encumbrance_total numeric(15, 2),
    proj_available_balance numeric(15, 2) NOT NULL,
    costsharing numeric(15, 2),
    proj_balance_after_costsharing numeric(15, 2) NOT NULL,
    grant_officer varchar,              -- TODO: Can have NULL
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP,
    last_modified timestamptz DEFAULT CURRENT_TIMESTAMP
);

-- Insert from pfr_clean.csv - needs to use psql. Works.
\copy staging_pfr (project_id, contract_number, fund_code, last_name, first_name, department,
division, subdivision, proj_sponsor, proj_title, award_number, proj_type, fringe_rate, irb, iacuc, proj_start_date,
proj_end_date, award_end_date, proj_status, total_revenue, proj_budget, proj_transfer_total, 
proj_total_cost, proj_balance, proj_encumbrance_total, proj_available_balance, 
costsharing, proj_balance_after_costsharing, grant_officer)
FROM /tmp/pfr_clean_db.csv WITH (FORMAT CSV, HEADER, NULL 'NA', encoding 'windows-1251')

-- Insert using postgres, not recommended since needs superuser
COPY staging_pfr
FROM '/tmp/pfr_clean_db.csv'
WITH (FORMAT CSV, HEADER);

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--TODO: Other data input. Staging tables for Cost details and Rev details. No Act_Sum



-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- PFR view - include PK if writing back to table
CREATE OR REPLACE VIEW ams_db.pfr AS
SELECT 



-- WITH CHECK OPTION; -- only works on views w/ no triggers


-- SELECT c.last_tract, f.fact_type+id, f.val
-- FROM census.facts As f INNER JOIN cte2 c ON f.tract_id = c.last_tract;

-- Trigger update fn - need to add delete, update cases
-- PL/sql? or PL/python/R? PL/pgsql
CREATE OR REPLACE FUNCTION ams_db.trig_pfr_ins_upd_del() RETURNS
trigger AS
$$
BEGIN

END;
$$
LANGUAGE plpgsql VOLATILE; -- may have more args


-- Bind trigger to veiw
CREATE TRIGGER trig_pfr_ins_upd_del
INSTEAD OF INSERT OR UPDATE OR DELETE ON pfr
FOR EACH ROW EXECUTE PROCEDURE ams_db.trig_pfr_ins_upd_del();

-- Data insert - Test on 1 row insert?
-- COPY




-- NOTE:
-- * Views only work on permissioned users. Set permissions so
--   data is read only for certain users. Ray should have all delete
--   priveleges. 
-- * Useful resource: https://hasura.io/blog/the-pros-and-cons-of-updatable-views/
-- * Need to write temp upload table. See how this process is, 
--    1) Upload COPY csv. 2) Insert into temp table. 3) Insert into view using 
--     trigger
-- * I think inserts are only based on app? This will usually be a copy?
--   So most of the db/app will be read only. But users have to edit(update)
--   fields. This is where triggers start.

-- * I do not need to write triggers just yet. 
-- UPDATE: Nvm, /copy only works on tables. 

-- NOTE: 
-- Upload process:
--      1) Upload COPY csv. 
--      2) Insert into temp table. 
--      3) Insert into view using trigger
-- SEE: https://www.postgresql.org/docs/current/populate.html
--  Insert new rows from app 
--      2) Insert into temp table. 3) Insert into view using trigger

-- * How am I going to automate this process? 
--   Have to automate staging table insert to view, view auto inserts to prod.
--   tables. 
--   Updates/ single app inserts will be different. Figure out.



