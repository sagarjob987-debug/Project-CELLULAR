CREATE EXTENSION IF NOT EXISTS timescaledb;
CREATE TABLE bms_telemetry (time TIMESTAMPTZ NOT NULL, asset_uid VARCHAR(64), voltage FLOAT, current FLOAT, temperature FLOAT);