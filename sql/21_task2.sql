DROP TABLE IF EXISTS task2_client_daily;

CREATE TABLE task2_client_daily AS
WITH
base_clients AS (
  SELECT client_id
  FROM task1_clients
),
base_accounts AS (
  SELECT a.account_id, a.client_id
  FROM accounts a
  JOIN base_clients bc
    ON bc.client_id = a.client_id
),
daily_net AS (
  SELECT
    a.client_id,
    o.created_at::date AS op_date,
    SUM(
      CASE o.direction
        WHEN 1 THEN -o.amount
        WHEN 2 THEN  o.amount
        ELSE 0
      END
    )::NUMERIC(18,2) AS net_amount
  FROM accounts a
  JOIN base_clients bc
    ON bc.client_id = a.client_id
  JOIN operations o
    ON o.account_id = a.account_id
  WHERE o.created_at >= (CURRENT_DATE - 6)::timestamp
    AND o.created_at <  (CURRENT_DATE + 1)::timestamp
  GROUP BY a.client_id, o.created_at::date
)

SELECT
  client_id,
  op_date,
  net_amount
FROM daily_net
WHERE net_amount < -2000
   OR net_amount > 10000
ORDER BY client_id, op_date;