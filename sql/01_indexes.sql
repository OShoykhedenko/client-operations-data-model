CREATE INDEX IF NOT EXISTS idx_contracts_client
ON contracts(client_id);

CREATE INDEX IF NOT EXISTS idx_contracts_account
ON contracts(account_id);

CREATE INDEX IF NOT EXISTS idx_operations_account_time
ON operations(account_id, created_at);