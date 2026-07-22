-- Enable TimescaleDB extension
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- 1. Assets Table (Vehicles & Batteries)
CREATE TABLE assets (
    asset_uid VARCHAR(64) PRIMARY KEY,
    vehicle_type VARCHAR(50), -- e.g., 'Mining Dump Truck', 'Logistics Semi'
    oem VARCHAR(50),
    battery_chemistry VARCHAR(20), -- 'LFP' or 'NMC'
    manufacture_date TIMESTAMP,
    current_soh FLOAT DEFAULT 100.0 -- State of Health
);

-- 2. Supply Chain Nodes (GNN Graph Data)
CREATE TABLE supply_chain_nodes (
    node_id VARCHAR(64) PRIMARY KEY,
    company_name VARCHAR(255),
    tier INTEGER,
    gst_status VARCHAR(50),
    financial_distress_score FLOAT DEFAULT 0.0,
    last_updated TIMESTAMP
);

-- 3. Maintenance Work Orders (SAP Integration)
CREATE TABLE work_orders (
    wo_id SERIAL PRIMARY KEY,
    asset_uid VARCHAR(64) REFERENCES assets(asset_uid),
    issue_description TEXT,
    predicted_failure_date TIMESTAMP,
    status VARCHAR(50) DEFAULT 'Draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. 10Hz BMS Telemetry (Timescale Hypertable)
CREATE TABLE bms_telemetry (
    time TIMESTAMPTZ NOT NULL,
    asset_uid VARCHAR(64) REFERENCES assets(asset_uid),
    voltage FLOAT,
    current FLOAT,
    temperature FLOAT,
    is_thermal_event BOOLEAN DEFAULT FALSE
);

-- Convert telemetry table to TimescaleDB hypertable
SELECT create_hypertable('bms_telemetry', 'time', chunk_time_interval => INTERVAL '1 day');

-- Create index for fast asset queries
CREATE INDEX idx_telemetry_asset ON bms_telemetry (asset_uid, time DESC);
