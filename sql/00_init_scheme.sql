CREATE TABLE IF NOT EXISTS client_status_dict (
    client_status_id  SMALLINT PRIMARY KEY,
    code              TEXT UNIQUE NOT NULL,         -- 'active', 'closed'
    name              TEXT NOT NULL,
    is_terminal       BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE IF NOT EXISTS clients (
    client_id           BIGSERIAL PRIMARY KEY,
    name                TEXT NOT NULL,
    client_status_id    SMALLINT NOT NULL REFERENCES client_status_dict(client_status_id),
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS contract_type_dict (
    contract_type_id  SMALLINT PRIMARY KEY,
    code              TEXT UNIQUE NOT NULL,
    name              TEXT NOT NULL,
    is_active         BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE contract_status_dict (
    contract_status_id SMALLINT PRIMARY KEY,
    code               TEXT UNIQUE NOT NULL,      -- active/closed/pending/...
    name               TEXT NOT NULL,
    is_terminal        BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE accounts (
    account_id    BIGINT PRIMARY KEY,
    client_id     BIGINT NOT NULL REFERENCES clients(client_id),
    opened_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    closed_at     TIMESTAMP NULL
);

CREATE TABLE IF NOT EXISTS contracts (
    contract_id          BIGSERIAL PRIMARY KEY,
    client_id            BIGINT NOT NULL REFERENCES clients(client_id),
    contract_type_id     SMALLINT NOT NULL REFERENCES contract_type_dict(contract_type_id),
    contract_status_id   SMALLINT NOT NULL REFERENCES contract_status_dict(contract_status_id),
    created_date         DATE NOT NULL,
    closed_date          DATE,
    account_id           BIGINT REFERENCES accounts(account_id),
    created_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS currency_dict (
    currency_id   SMALLINT PRIMARY KEY,
    code char(3)  UNIQUE NOT NULL,
    name          TEXT NOT NULL,
    is_active     BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS operations (
    operation_id    BIGSERIAL PRIMARY KEY,
    account_id      BIGINT REFERENCES accounts(account_id),
    currency_id     SMALLINT NOT NULL REFERENCES currency_dict(currency_id),
    amount          NUMERIC(18,2) NOT NULL CHECK (amount >= 0),
    direction       SMALLINT NOT NULL CHECK (direction IN (1,2)),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

