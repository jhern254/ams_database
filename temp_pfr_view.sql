-- Temp pfr_view w/ no personnel
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- PFR view - include PK if writing back to table
CREATE OR REPLACE VIEW pfr_temp AS 
SELECT rp.project_id, rp.contract_number, rp.fund_code,  
    rp.department, rp.division, rp.subdivision, rp.proj_sponsor,
    rp.proj_title, rp.award_number, rp.proj_type, rp.irb, 
    rp.iacuc, rp.proj_start_date, rp.proj_end_date, pb.award_end_date, 
    rp.proj_status, pb.total_revenue, pb.proj_budget, pc.proj_transfer_total,
    pc.proj_total_cost, pb.proj_balance, pc.proj_encumbrance_total,
    pb.proj_available_balance, pc.costsharing, pb.proj_balance_after_costsharing,
    pb.grant_officer, rp.rp_created_at, rp.rp_updated_at
FROM research_projects rp JOIN project_budget pb
    ON rp.project_id = pb.project_id
JOIN project_costs pc
    ON rp.project_id = pc.project_id


-- Trigger update fn - need to add delete, update cases
-- TODO: Add proper time stamp updates
CREATE OR REPLACE FUNCTION pfr_temp_on_insert() RETURNS
trigger AS
$$
BEGIN
    IF (TG_OP = 'INSERT') THEN  -- NEW. ?
        INSERT INTO research_projects(project_id, contract_number, fund_code,
            department, division, subdivision, proj_sponsor, proj_title, 
            award_number, proj_type, irb, iacuc, proj_start_date, proj_end_date,
            proj_status)
        SELECT NEW.project_id, NEW.contract_number, NEW.fund_code, 
            NEW.department, NEW.division, NEW.subdivision, NEW.proj_sponsor,
            NEW.proj_title, NEW.award_number, NEW.proj_type, NEW.irb, NEW.iacuc,
            NEW.proj_start_date, NEW.proj_end_date, NEW.proj_status;

        INSERT INTO project_budget(project_id, proj_budget, total_revenue, 
            proj_balance, proj_available_balance, proj_balance_after_costsharing,
            award_end_date, grant_officer)
        SELECT NEW.project_id, NEW.proj_budget, NEW.total_revenue, 
            NEW.proj_balance, NEW.proj_available_balance, 
            NEW.proj_balance_after_costsharing, NEW.award_end_date, 
            NEW.grant_officer;

        INSERT INTO project_costs(project_id, proj_total_cost, 
            proj_transfer_total, proj_encumbrance_total, costsharing)
        SELECT NEW.project_id, NEW.proj_total_cost, 
            NEW.proj_transfer_total, NEW.proj_encumbrance_total, NEW.costsharing;
        RETURN NEW;
    END IF;
END;
$$
LANGUAGE plpgsql VOLATILE; -- may have more args


-- Bind trigger to veiw
CREATE TRIGGER pfr_temp_on_insert_trigger
INSTEAD OF INSERT ON pfr_temp 
FOR EACH ROW EXECUTE PROCEDURE pfr_temp_on_insert();


-- Data insert - Test on 1 row insert
INSERT INTO pfr_temp
    (project_id, contract_number, fund_code,  
        department, division, subdivision, proj_sponsor,
        proj_title, award_number, proj_type, irb, 
        iacuc, proj_start_date, proj_end_date, award_end_date, 
        proj_status, total_revenue, proj_budget, proj_transfer_total,
        proj_total_cost, proj_balance, proj_encumbrance_total,
        proj_available_balance, costsharing, proj_balance_after_costsharing,
        grant_officer)
SELECT 
    project_id, contract_number, fund_code,  
        department, division, subdivision, proj_sponsor,
        proj_title, award_number, proj_type, irb, 
        iacuc, proj_start_date, proj_end_date, award_end_date, 
        proj_status, total_revenue, proj_budget, proj_transfer_total,
        proj_total_cost, proj_balance, proj_encumbrance_total,
        proj_available_balance, costsharing, proj_balance_after_costsharing,
        grant_officer
FROM staging_pfr 
WHERE project_id = 146375;

-- HERE:check correctness and test in postgres






