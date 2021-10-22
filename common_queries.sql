-- Common queries
-- PFR data
-- TODO: write as views once queries are efficient

-- Current balance on specific projects
-- rewrite as CTE
SELECT rp.project_id, pb.proj_balance, pb.proj_available_balance, rp.proj_status
FROM research_projects rp JOIN project_budget pb
ON rp.project_id = pb.project_id
WHERE rp.proj_status = 'O';
--LIMIT 20;

-- Current project costs
SELECT rp.project_id, pb.proj_budget, pc.proj_total_cost, pb.proj_balance,
    rp.proj_status
FROM research_projects rp JOIN project_costs pc
    ON rp.project_id = pc.project_id
JOIN project_budget pb
    ON rp.project_id = pb.project_id
WHERE rp.proj_status = 'O';


-- F/A rate. Need PPE EID records
-- Need personnel records to add PI name to queries.

-- Aggregate queries, how many open, closed projs?
-- Do data analysis queries



