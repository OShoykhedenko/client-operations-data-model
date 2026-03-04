DROP TABLE IF EXISTS task1_clients;

CREATE TABLE task1_clients AS

WITH
active_clients AS (
  SELECT c.client_id
  FROM clients c
  JOIN client_status_dict cs
    ON cs.client_status_id = c.client_status_id
  WHERE cs.code = 'active'
),

clients_with_credit_deposit AS (
  SELECT ct.client_id
  FROM contracts ct
  JOIN contract_type_dict t
    ON t.contract_type_id = ct.contract_type_id
  JOIN contract_status_dict st
    ON st.contract_status_id = ct.contract_status_id
  WHERE st.code = 'active'
    AND t.code IN ('credit','deposit')
  GROUP BY ct.client_id
  HAVING BOOL_OR(t.code='credit') AND BOOL_OR(t.code='deposit')
),

ops_30d AS (
  SELECT
    a.client_id,
    SUM(o.amount) AS ops_volume_30d
  FROM accounts a
  JOIN operations o
    ON o.account_id = a.account_id
  WHERE o.created_at >= NOW() - INTERVAL '30 days'
  GROUP BY a.client_id
)

SELECT
  ac.client_id,
  op.ops_volume_30d
FROM active_clients ac
JOIN clients_with_credit_deposit cd
  ON cd.client_id = ac.client_id
JOIN ops_30d op
  ON op.client_id = ac.client_id
WHERE op.ops_volume_30d > 20000;