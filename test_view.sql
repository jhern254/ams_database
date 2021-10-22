-- write test view w/ small number of cols. but many joins
CREATE OR REPLACE VIEW test_view AS
SELECT rp.project_id, rp.proj_type, rp.proj_status, 
    pb.proj_budget, pb.proj_balance, pb.proj_available_balance,
    pb.proj_balance_after_costsharing, 
    pc.proj_total_cost -- might need timestamps 

-- TODO: write proper timestamp update code
FROM research_projects rp JOIN project_budget pb
    ON rp.project_id = pb.project_id
JOIN project_costs pc
    ON rp.project_id = pc.project_id;

-- Trigger
CREATE OR REPLACE FUNCTION trig_test_view_ins() RETURNS
trigger AS
$$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO research_projects(project_id, proj_type, proj_status)
        SELECT NEW.project_id, NEW.proj_type, NEW.proj_status;
-- No UNION?
        INSERT INTO project_budget(project_id, proj_budget, proj_balance, 
            proj_available_balance, proj_balance_after_costsharing)
        SELECT NEW.project_id, NEW.proj_budget, NEW.proj_balance, 
            NEW.proj_available_balance, NEW.proj_balance_after_costsharing;
            
        INSERT INTO project_costs(project_id, proj_total_cost)
        SELECT NEW.project_id, NEW.proj_total_cost;
        RETURN NEW;
    END IF;
END;
$$
LANGUAGE plpgsql VOLATILE;

-- TODO: Write delete and update fns

-- Bind trigger to view
CREATE TRIGGER trig_test_view_ins
INSTEAD OF INSERT ON test_view-- OR UPDATE OR DELETE
FOR EACH ROW EXECUTE PROCEDURE trig_test_view_ins();

-- write test insert
INSERT INTO test_view
    (project_id, proj_type, proj_status, 
        proj_budget, proj_balance, proj_available_balance,
        proj_balance_after_costsharing, 
        proj_total_cost)
SELECT 
    project_id, proj_type, proj_status, 
        proj_budget, proj_balance, proj_available_balance,
        proj_balance_after_costsharing, 
        proj_total_cost

FROM staging_pfr
WHERE project_id = 234739;
-- works
