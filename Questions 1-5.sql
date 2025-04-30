-- 2.4.1 Pricing Summary Report Query (Q1)
-- This query reports the amount of business that was billed, shipped, and returned.
-- 2.4.1.1 Business Question
-- The Pricing Summary Report Query provides a summary pricing report for all lineitems shipped as of a given date.
-- The date is within 60 - 120 days of the greatest ship date contained in the database. The query lists totals for
-- extended price, discounted extended price, discounted extended price plus tax, average quantity, average extended
-- price, and average discount. These aggregates are grouped by RETURNFLAG and LINESTATUS, and listed in
-- ascending order of RETURNFLAG and LINESTATUS. A count of the number of lineitems in each group is
-- included.

WITH max_date AS (
  SELECT MAX(l_shipdate) AS latest_ship_date
  FROM lineitem
)

SELECT l_returnflag, l_linestatus,
    SUM(l_extendedprice) AS gross_revenue,
    SUM(l_extendedprice * (1 - l_discount)) AS discounted_revenue,
    SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)) AS taxed_n_discounted_revenue,
    AVG(l_quantity) AS average_quantity,
    AVG(l_extendedprice) AS average_revenue,
    AVG(l_discount) AS average_discount
FROM lineitem
JOIN max_date ON 1=1
WHERE l_shipdate
    BETWEEN DATEADD('day', -120, latest_ship_date) AND DATEADD('day', -60, latest_ship_date)
GROUP BY 1,2
ORDER BY l_returnflag, l_linestatus

-- 2.4.2 Minimum Cost Supplier Query (Q2)
-- This query finds which supplier should be selected to place an order for a given part in a given region.
-- 2.4.2.1 Business Question
-- The Minimum Cost Supplier Query finds, in a given region, for each part of a certain type and size, the supplier who
-- can supply it at minimum cost. If several suppliers in that region offer the desired part type and size at the same
-- (minimum) cost, the query lists the parts from suppliers with the 100 highest account balances. For each supplier,
-- the query lists the supplier's account balance, name and nation; the part's number and manufacturer; the supplier's
-- address, phone number and comment information.

WITH joined AS (
SELECT r_name, s_name, p_partkey, p_type, p_size, ps_supplycost,
RANK() OVER(PARTITION BY p_type, p_size ORDER BY ps_supplycost ASC) AS cost_rank
FROM region AS R
INNER JOIN nation AS N
    ON r_regionkey = n_regionkey
INNER JOIN supplier AS S
    ON n_nationkey = s_nationkey
INNER JOIN partsupp AS PS
    ON s_suppkey = ps_suppkey
INNER JOIN part AS P
    ON ps_partkey = p_partkey
WHERE p_size BETWEEN 1 AND 10
    AND p_type IN ('MEDIUM POLISHED NICKEL', 'BRASS', 'BRONZE', 'STEEL')
    AND r_name = 'EUROPE'
)

// Checks for a given part type & size combo where there are multiple suppliers offering the cheapest price - There are none
-- SELECT p_type, p_size, COUNT(cost_rank)
-- FROM joined
-- WHERE cost_rank = 1
-- GROUP BY 1,2

SELECT *
FROM joined
