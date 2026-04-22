-- V5__Add_country_column.sql
-- Zero-downtime migration: Add country column with default value
ALTER TABLE employees ADD COLUMN country VARCHAR(100) DEFAULT 'USA';

-- Update Okeke Finbarr's country to Nigeria
UPDATE employees SET country = 'Nigeria' WHERE first_name = 'Okeke' AND last_name = 'Finbarr';
