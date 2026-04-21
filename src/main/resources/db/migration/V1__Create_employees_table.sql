-- V1__Create_employees_table.sql
CREATE TABLE employees (
    id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    department VARCHAR(100),
    position VARCHAR(100),
    salary DECIMAL(10, 2),
    hire_date DATE NOT NULL
);

CREATE INDEX idx_department ON employees(department);
CREATE INDEX idx_email ON employees(email);
