-- V3__Add_phone_column.sql
ALTER TABLE employees ADD COLUMN phone VARCHAR(20);

UPDATE employees SET phone = '+1-555-0101' WHERE id = 1;
UPDATE employees SET phone = '+1-555-0102' WHERE id = 2;
UPDATE employees SET phone = '+1-555-0103' WHERE id = 3;
UPDATE employees SET phone = '+1-555-0104' WHERE id = 4;
UPDATE employees SET phone = '+1-555-0105' WHERE id = 5;
