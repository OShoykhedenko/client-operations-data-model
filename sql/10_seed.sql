BEGIN;

TRUNCATE TABLE
  operations,
  contracts,
  accounts,
  clients,
  currency_dict,
  contract_type_dict,
  contract_status_dict,
  client_status_dict
RESTART IDENTITY CASCADE;

-- 1) Dictionaries
INSERT INTO client_status_dict (client_status_id, code, name, is_terminal) VALUES
  (1, 'active', 'Активный', false),
  (2, 'closed', 'Закрытый', true);

INSERT INTO contract_status_dict (contract_status_id, code, name, is_terminal) VALUES
  (1, 'active', 'Активный', false),
  (2, 'closed', 'Закрытый', true);

INSERT INTO contract_type_dict (contract_type_id, code, name, is_active) VALUES
  (1, 'credit',     'Кредит',      true),
  (2, 'deposit',    'Депозит',     true),
  (3, 'ovgz',       'ОВГЗ',        true),
  (4, 'account_dt', 'Счет Дт',     true),
  (5, 'account_ct', 'Счет Кт',     true);

INSERT INTO currency_dict (currency_id, code, name, is_active) VALUES
  (1, 'USD', 'US Dollar',  true),
  (2, 'EUR', 'Euro',       true),
  (3, 'UAH', 'Hryvnia',     true);

-- 2) Clients (explicit IDs for reproducibility)
INSERT INTO clients (client_id, name, client_status_id, created_at, updated_at) VALUES
  (1001, 'Alice', 1, now() - interval '60 days', now() - interval '1 day'),
  (1002, 'Bob',   1, now() - interval '40 days', now() - interval '2 days'),
  (1003, 'Carol', 2, now() - interval '90 days', now() - interval '10 days');

-- 3) Accounts
-- Alice has two accounts (to link credit + deposit to different accounts)
-- Bob has one account
INSERT INTO accounts (account_id, client_id, opened_at, closed_at) VALUES
  (50001, 1001, now() - interval '50 days', NULL),
  (50002, 1001, now() - interval '45 days', NULL),
  (50003, 1002, now() - interval '35 days', NULL);

-- 4) Contracts
-- Alice: active credit + active deposit => should satisfy Task1 type condition
-- Bob: only credit => should NOT satisfy Task1
INSERT INTO contracts (
  contract_id, client_id, contract_type_id, contract_status_id,
  account_id, created_date, closed_date, created_at, updated_at
) VALUES
  (20001, 1001, 1, 1, 50001, current_date - 50, NULL, now() - interval '50 days', now() - interval '2 days'), -- credit active
  (20002, 1001, 2, 1, 50002, current_date - 45, NULL, now() - interval '45 days', now() - interval '2 days'), -- deposit active
  (20003, 1002, 1, 1, 50003, current_date - 35, NULL, now() - interval '35 days', now() - interval '3 days'); -- credit active

-- 5) Operations
-- direction: 1 = DT (minus), 2 = CT (plus)
-- currency_id: 1 = USD
--
-- For Alice:
-- - Total volume (SUM(amount)) in last 30 days > 20000 (we add ~30k)
-- - In last 7 days:
--     day -1: net > 10000
--     day -2: net < -2000

-- Helper timestamps: we use CURRENT_DATE with fixed times for clarity

-- Alice, last 7 days extremes
INSERT INTO operations (operation_id, account_id, currency_id, amount, direction, created_at) VALUES
  -- Day -1: net +11000 (CT 12000 - DT 1000)
  (30001, 50001, 1, 12000.00, 2, (current_date - 1) + time '10:00'),
  (30002, 50001, 1,  1000.00, 1, (current_date - 1) + time '12:00'),

  -- Day -2: net -3000 (DT 3000)
  (30003, 50002, 1,  3000.00, 1, (current_date - 2) + time '11:00'),

  -- Other days within last 7 days (small noise)
  (30004, 50001, 1,   200.00, 2, (current_date - 3) + time '09:15'),
  (30005, 50002, 1,   150.00, 1, (current_date - 4) + time '16:20'),
  (30006, 50001, 1,   500.00, 2, (current_date - 5) + time '14:05'),
  (30007, 50002, 1,   400.00, 1, (current_date - 6) + time '18:45');

-- Alice, additional operations within last 30 days to push volume > 20000
-- Add several medium ops on earlier dates (still within 30 days)
INSERT INTO operations (operation_id, account_id, currency_id, amount, direction, created_at) VALUES
  (30008, 50001, 1, 4000.00, 2, (current_date - 10) + time '10:00'),
  (30009, 50002, 1, 3500.00, 1, (current_date - 12) + time '10:30'),
  (30010, 50001, 1, 5000.00, 2, (current_date - 15) + time '13:00'),
  (30011, 50002, 1, 4500.00, 2, (current_date - 20) + time '09:00'),
  (30012, 50001, 1, 3200.00, 1, (current_date - 25) + time '17:10');

-- Bob: some ops but should not qualify for Task1 because he lacks deposit
INSERT INTO operations (operation_id, account_id, currency_id, amount, direction, created_at) VALUES
  (30101, 50003, 1, 9000.00, 2, (current_date - 3) + time '10:00'),
  (30102, 50003, 1, 1000.00, 1, (current_date - 2) + time '10:00');