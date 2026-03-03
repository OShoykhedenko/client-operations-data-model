CREATE TABLE IF NOT EXISTS clients (
    client_id      BIGSERIAL PRIMARY KEY,
    name           TEXT NOT NULL,
    is_active      BOOLEAN NOT NULL, -- TRUE = активный, FALSE = закрытый
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TYPE contract_type_enum AS ENUM (
    'credit',
    'deposit',
    'ovgz',
    'account_dt',
    'account_ct'
);

CREATE TABLE IF NOT EXISTS contracts (
    contract_id     BIGSERIAL PRIMARY KEY,
    client_id       BIGINT NOT NULL REFERENCES clients(client_id),
    contract_type contract_type_enum NOT NULL;
    is_active       BOOLEAN NOT NULL, -- TRUE = активный, FALSE = закрытый
    created_date    DATE NOT NULL,
    closed_date     DATE,
    account_id      BIGINT NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TYPE currency_enum AS ENUM ('USD', 'EUR', 'UAH');

CREATE TABLE IF NOT EXISTS operations (
    operation_id   BIGSERIAL PRIMARY KEY,
    account_id     BIGINT NOT NULL,
    currency currency_enum NOT NULL;
    amount         NUMERIC(18,2) NOT NULL CHECK (amount >= 0),
    direction      TEXT NOT NULL CHECK (direction IN ('Дт','Кт')),
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

