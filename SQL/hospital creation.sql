CREATE SCHEMA hospital;

--- creating departments table
CREATE TABLE hospital.departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

--- inserting department names
INSERT INTO hospital.departments (department_name)
VALUES
    ('Cardiology'),
    ('Pediatrics'),
    ('General Medicine'),
    ('Dermatology'),
    ('Orthopedics'),
    ('Emergency');

--- creating doctor table
CREATE TABLE hospital.doctors (
    doctor_id SERIAL PRIMARY KEY,
    doctor_name VARCHAR(100) NOT NULL,
    department_id INTEGER REFERENCES hospital.departments(department_id),
    specialization VARCHAR(100),
    phone VARCHAR(20) UNIQUE
);

--- inserting doctor information
INSERT INTO hospital.doctors
    (doctor_name, department_id, specialization, phone)
VALUES
    ('Dr. Ahmed Hassan', 1, 'Cardiologist', '0701000001'),
    ('Dr. Mary James', 2, 'Pediatrician', '0701000002'),
    ('Dr. John Peter', 3, 'General Physician', '0701000003'),
    ('Dr. Sarah Ali', 4, 'Dermatologist', '0701000004'),
    ('Dr. David Mwangi', 5, 'Orthopedic Surgeon', '0701000005'),
    ('Dr. Fatima Omar', 6, 'Emergency Physician', '0701000006'),
    ('Dr. James Kariuki', 1, 'Cardiologist', '0701000007'),
    ('Dr. Amina Yusuf', 2, 'Pediatrician', '0701000008'),
    ('Dr. Peter Otieno', 3, 'General Physician', '0701000009'),
    ('Dr. Grace Wanjiku', 4, 'Dermatologist', '0701000010'),
    ('Dr. Hassan Ibrahim', 5, 'Orthopedic Surgeon', '0701000011'),
    ('Dr. Lucy Njeri', 6, 'Emergency Physician', '0701000012'),
    ('Dr. Mohamed Abdi', 1, 'Cardiologist', '0701000013'),
    ('Dr. Esther Kamau', 2, 'Pediatrician', '0701000014'),
    ('Dr. Daniel Maina', 3, 'General Physician', '0701000015');

-- Create the patients table

CREATE TABLE hospital.patients (
    patient_id SERIAL PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10),
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(150) UNIQUE,
    registration_date DATE DEFAULT CURRENT_DATE
);

-- Insert patient records

INSERT INTO hospital.patients
    (patient_name, date_of_birth, gender, phone, email, registration_date)
VALUES
    ('Ahmed Hassan', '1990-04-12', 'Male', '0711000001', 'ahmed1@email.com', '2026-01-05'),
    ('Mary James', '1985-09-23', 'Female', '0711000002', 'mary2@email.com', '2026-01-07'),
    ('John Peter', '2001-02-14', 'Male', '0711000003', 'john3@email.com', '2026-01-10'),
    ('Sarah Ali', '1995-11-30', 'Female', '0711000004', 'sarah4@email.com', '2026-01-12'),
    ('David Mwangi', '1978-06-18', 'Male', '0711000005', 'david5@email.com', '2026-01-15'),
    ('Fatima Omar', '2005-03-08', 'Female', '0711000006', 'fatima6@email.com', '2026-01-18'),
    ('James Kariuki', '1965-12-01', 'Male', '0711000007', 'james7@email.com', '2026-01-20'),
    ('Amina Yusuf', '1998-07-25', 'Female', '0711000008', 'amina8@email.com', '2026-01-22'),
    ('Peter Otieno', '1988-01-16', 'Male', '0711000009', 'peter9@email.com', '2026-01-25'),
    ('Grace Wanjiku', '2010-05-19', 'Female', '0711000010', 'grace10@email.com', '2026-01-28');

-- Insert 90 additional patients

INSERT INTO hospital.patients
    (patient_name, date_of_birth, gender, phone, email, registration_date)
SELECT
    'Patient ' || n,
    DATE '1950-01-01' + (n * 137 % 25000),
    CASE WHEN n % 2 = 0 THEN 'Female' ELSE 'Male' END,
    '0712' || LPAD(n::TEXT, 6, '0'),
    'patient' || n || '@email.com',
    DATE '2026-02-01' + (n * 3 % 280)
FROM generate_series(11, 100) AS n;


-- Create and populate the remaining hospital tables

BEGIN;

-- 1. Create appointments

CREATE TABLE hospital.appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES hospital.patients(patient_id),
    doctor_id INTEGER NOT NULL REFERENCES hospital.doctors(doctor_id),
    appointment_date TIMESTAMP NOT NULL,
    reason VARCHAR(200),
    status VARCHAR(20) NOT NULL
);

-- Insert 250 appointments

INSERT INTO hospital.appointments
    (patient_id, doctor_id, appointment_date, reason, status)
SELECT
    ((n - 1) % 100) + 1,
    ((n - 1) % 15) + 1,
    TIMESTAMP '2026-01-01 08:00:00'
        + ((n * 7) % 314) * INTERVAL '1 day'
        + (n % 9) * INTERVAL '1 hour',
    CASE
        WHEN n % 5 = 0 THEN 'Routine checkup'
        WHEN n % 5 = 1 THEN 'Follow-up consultation'
        WHEN n % 5 = 2 THEN 'Pain or discomfort'
        WHEN n % 5 = 3 THEN 'General examination'
        ELSE 'Specialist consultation'
    END,
    CASE
        WHEN n % 10 = 0 THEN 'Cancelled'
        WHEN n % 10 = 1 THEN 'No-show'
        WHEN n % 10 = 2 THEN 'Scheduled'
        ELSE 'Completed'
    END
FROM generate_series(1, 250) AS gs(n);


-- 2. Create admissions

CREATE TABLE hospital.admissions (
    admission_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES hospital.patients(patient_id),
    doctor_id INTEGER NOT NULL REFERENCES hospital.doctors(doctor_id),
    appointment_id INTEGER UNIQUE REFERENCES hospital.appointments(appointment_id),
    admission_date DATE NOT NULL,
    discharge_date DATE,
    admission_reason VARCHAR(200),
    status VARCHAR(20) NOT NULL
);

-- Insert 40 admissions

INSERT INTO hospital.admissions
    (patient_id, doctor_id, appointment_id, admission_date,
     discharge_date, admission_reason, status)
SELECT
    a.patient_id,
    a.doctor_id,
    a.appointment_id,
    a.appointment_date::DATE,
    (a.appointment_date::DATE + (2 + n % 9)),
    CASE
        WHEN n % 4 = 0 THEN 'Observation and monitoring'
        WHEN n % 4 = 1 THEN 'Surgical procedure'
        WHEN n % 4 = 2 THEN 'Medical treatment'
        ELSE 'Emergency care'
    END,
    'Discharged'
FROM hospital.appointments a
JOIN generate_series(1, 40) AS gs(n)
    ON a.appointment_id = n;


-- 3. Create medicines

CREATE TABLE hospital.medicines (
    medicine_id SERIAL PRIMARY KEY,
    medicine_name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

-- Insert 30 medicines

INSERT INTO hospital.medicines
    (medicine_name, category, unit_price, stock_quantity)
VALUES
    ('Paracetamol', 'Pain Relief', 50.00, 500),
    ('Ibuprofen', 'Pain Relief', 80.00, 300),
    ('Amoxicillin', 'Antibiotic', 150.00, 200),
    ('Azithromycin', 'Antibiotic', 250.00, 150),
    ('Cetirizine', 'Antihistamine', 60.00, 250),
    ('Loratadine', 'Antihistamine', 90.00, 200),
    ('Omeprazole', 'Gastrointestinal', 120.00, 180),
    ('Antacid Tablets', 'Gastrointestinal', 40.00, 300),
    ('Metformin', 'Diabetes', 100.00, 250),
    ('Insulin', 'Diabetes', 800.00, 80),
    ('Amlodipine', 'Cardiovascular', 110.00, 200),
    ('Losartan', 'Cardiovascular', 140.00, 180),
    ('Salbutamol Inhaler', 'Respiratory', 350.00, 100),
    ('Cough Syrup', 'Respiratory', 130.00, 160),
    ('Vitamin C', 'Vitamins', 70.00, 300),
    ('Vitamin D', 'Vitamins', 150.00, 180),
    ('Iron Tablets', 'Supplements', 90.00, 220),
    ('Calcium Tablets', 'Supplements', 120.00, 200),
    ('Hydrocortisone Cream', 'Dermatology', 180.00, 100),
    ('Antifungal Cream', 'Dermatology', 160.00, 120),
    ('Eye Drops', 'Eye Care', 100.00, 150),
    ('Ear Drops', 'Ear Care', 110.00, 100),
    ('ORS Sachets', 'Rehydration', 25.00, 500),
    ('Zinc Tablets', 'Supplements', 60.00, 250),
    ('Diclofenac', 'Pain Relief', 100.00, 180),
    ('Doxycycline', 'Antibiotic', 170.00, 140),
    ('Folic Acid', 'Vitamins', 50.00, 300),
    ('Multivitamins', 'Vitamins', 200.00, 160),
    ('Antiseptic Solution', 'First Aid', 90.00, 180),
    ('Loperamide', 'Gastrointestinal', 75.00, 200);


-- 4. Create prescriptions

CREATE TABLE hospital.prescriptions (
    prescription_id SERIAL PRIMARY KEY,
    appointment_id INTEGER NOT NULL UNIQUE
        REFERENCES hospital.appointments(appointment_id),
    prescription_date DATE NOT NULL,
    notes VARCHAR(250)
);

-- Insert 120 prescriptions

INSERT INTO hospital.prescriptions
    (appointment_id, prescription_date, notes)
SELECT
    appointment_id,
    appointment_date::DATE,
    CASE
        WHEN appointment_id % 3 = 0 THEN 'Take medication as directed'
        WHEN appointment_id % 3 = 1 THEN 'Complete the prescribed course'
        ELSE 'Return for follow-up if necessary'
    END
FROM hospital.appointments
WHERE appointment_id <= 120;


-- 5. Create prescription items

CREATE TABLE hospital.prescription_items (
    prescription_item_id SERIAL PRIMARY KEY,
    prescription_id INTEGER NOT NULL
        REFERENCES hospital.prescriptions(prescription_id),
    medicine_id INTEGER NOT NULL
        REFERENCES hospital.medicines(medicine_id),
    dosage VARCHAR(100) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    duration_days INTEGER NOT NULL CHECK (duration_days > 0)
);

-- Insert 200 prescription items

INSERT INTO hospital.prescription_items
    (prescription_id, medicine_id, dosage, quantity, duration_days)
SELECT
    ((n - 1) % 120) + 1,
    ((n - 1) % 30) + 1,
    CASE
        WHEN n % 3 = 0 THEN 'Once daily'
        WHEN n % 3 = 1 THEN 'Twice daily'
        ELSE 'Three times daily'
    END,
    5 + (n % 26),
    3 + (n % 12)
FROM generate_series(1, 200) AS gs(n);


-- 6. Create payments

CREATE TABLE hospital.payments (
    payment_id SERIAL PRIMARY KEY,
    appointment_id INTEGER REFERENCES hospital.appointments(appointment_id),
    admission_id INTEGER REFERENCES hospital.admissions(admission_id),
    amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    payment_date DATE NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    CHECK (
        (appointment_id IS NOT NULL AND admission_id IS NULL)
        OR
        (appointment_id IS NULL AND admission_id IS NOT NULL)
    )
);

-- Insert 180 payments

INSERT INTO hospital.payments
    (appointment_id, admission_id, amount, payment_date,
     payment_method, payment_status)
SELECT
    n,
    NULL,
    500 + (n % 10) * 250,
    a.appointment_date::DATE,
    CASE
        WHEN n % 3 = 0 THEN 'M-Pesa'
        WHEN n % 3 = 1 THEN 'Cash'
        ELSE 'Card'
    END,
    CASE
        WHEN n % 10 = 0 THEN 'Pending'
        WHEN n % 10 = 1 THEN 'Failed'
        ELSE 'Paid'
    END
FROM generate_series(1, 150) AS gs(n)
JOIN hospital.appointments a ON a.appointment_id = n

UNION ALL

SELECT
    NULL,
    n,
    5000 + (n % 10) * 1500,
    a.admission_date,
    CASE
        WHEN n % 3 = 0 THEN 'M-Pesa'
        WHEN n % 3 = 1 THEN 'Cash'
        ELSE 'Card'
    END,
    CASE
        WHEN n % 10 = 0 THEN 'Pending'
        WHEN n % 10 = 1 THEN 'Failed'
        ELSE 'Paid'
    END
FROM generate_series(1, 30) AS gs(n)
JOIN hospital.admissions a ON a.admission_id = n;


COMMIT;



-- Create and populate the remaining hospital tables

BEGIN;

-- 1. Create appointments

CREATE TABLE hospital.appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES hospital.patients(patient_id),
    doctor_id INTEGER NOT NULL REFERENCES hospital.doctors(doctor_id),
    appointment_date TIMESTAMP NOT NULL,
    reason VARCHAR(200),
    status VARCHAR(20) NOT NULL
);

-- Insert 250 appointments

INSERT INTO hospital.appointments
    (patient_id, doctor_id, appointment_date, reason, status)
SELECT
    ((n - 1) % 100) + 1,
    ((n - 1) % 15) + 1,
    TIMESTAMP '2026-01-01 08:00:00'
        + ((n * 7) % 314) * INTERVAL '1 day'
        + (n % 9) * INTERVAL '1 hour',
    CASE
        WHEN n % 5 = 0 THEN 'Routine checkup'
        WHEN n % 5 = 1 THEN 'Follow-up consultation'
        WHEN n % 5 = 2 THEN 'Pain or discomfort'
        WHEN n % 5 = 3 THEN 'General examination'
        ELSE 'Specialist consultation'
    END,
    CASE
        WHEN n % 10 = 0 THEN 'Cancelled'
        WHEN n % 10 = 1 THEN 'No-show'
        WHEN n % 10 = 2 THEN 'Scheduled'
        ELSE 'Completed'
    END
FROM generate_series(1, 250) AS gs(n);


-- 2. Create admissions

CREATE TABLE hospital.admissions (
    admission_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES hospital.patients(patient_id),
    doctor_id INTEGER NOT NULL REFERENCES hospital.doctors(doctor_id),
    appointment_id INTEGER UNIQUE REFERENCES hospital.appointments(appointment_id),
    admission_date DATE NOT NULL,
    discharge_date DATE,
    admission_reason VARCHAR(200),
    status VARCHAR(20) NOT NULL
);

-- Insert 40 admissions

INSERT INTO hospital.admissions
    (patient_id, doctor_id, appointment_id, admission_date,
     discharge_date, admission_reason, status)
SELECT
    a.patient_id,
    a.doctor_id,
    a.appointment_id,
    a.appointment_date::DATE,
    (a.appointment_date::DATE + (2 + n % 9)),
    CASE
        WHEN n % 4 = 0 THEN 'Observation and monitoring'
        WHEN n % 4 = 1 THEN 'Surgical procedure'
        WHEN n % 4 = 2 THEN 'Medical treatment'
        ELSE 'Emergency care'
    END,
    'Discharged'
FROM hospital.appointments a
JOIN generate_series(1, 40) AS gs(n)
    ON a.appointment_id = n;


-- 3. Create medicines

CREATE TABLE hospital.medicines (
    medicine_id SERIAL PRIMARY KEY,
    medicine_name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

-- Insert 30 medicines

INSERT INTO hospital.medicines
    (medicine_name, category, unit_price, stock_quantity)
VALUES
    ('Paracetamol', 'Pain Relief', 50.00, 500),
    ('Ibuprofen', 'Pain Relief', 80.00, 300),
    ('Amoxicillin', 'Antibiotic', 150.00, 200),
    ('Azithromycin', 'Antibiotic', 250.00, 150),
    ('Cetirizine', 'Antihistamine', 60.00, 250),
    ('Loratadine', 'Antihistamine', 90.00, 200),
    ('Omeprazole', 'Gastrointestinal', 120.00, 180),
    ('Antacid Tablets', 'Gastrointestinal', 40.00, 300),
    ('Metformin', 'Diabetes', 100.00, 250),
    ('Insulin', 'Diabetes', 800.00, 80),
    ('Amlodipine', 'Cardiovascular', 110.00, 200),
    ('Losartan', 'Cardiovascular', 140.00, 180),
    ('Salbutamol Inhaler', 'Respiratory', 350.00, 100),
    ('Cough Syrup', 'Respiratory', 130.00, 160),
    ('Vitamin C', 'Vitamins', 70.00, 300),
    ('Vitamin D', 'Vitamins', 150.00, 180),
    ('Iron Tablets', 'Supplements', 90.00, 220),
    ('Calcium Tablets', 'Supplements', 120.00, 200),
    ('Hydrocortisone Cream', 'Dermatology', 180.00, 100),
    ('Antifungal Cream', 'Dermatology', 160.00, 120),
    ('Eye Drops', 'Eye Care', 100.00, 150),
    ('Ear Drops', 'Ear Care', 110.00, 100),
    ('ORS Sachets', 'Rehydration', 25.00, 500),
    ('Zinc Tablets', 'Supplements', 60.00, 250),
    ('Diclofenac', 'Pain Relief', 100.00, 180),
    ('Doxycycline', 'Antibiotic', 170.00, 140),
    ('Folic Acid', 'Vitamins', 50.00, 300),
    ('Multivitamins', 'Vitamins', 200.00, 160),
    ('Antiseptic Solution', 'First Aid', 90.00, 180),
    ('Loperamide', 'Gastrointestinal', 75.00, 200);


-- 4. Create prescriptions

CREATE TABLE hospital.prescriptions (
    prescription_id SERIAL PRIMARY KEY,
    appointment_id INTEGER NOT NULL UNIQUE
        REFERENCES hospital.appointments(appointment_id),
    prescription_date DATE NOT NULL,
    notes VARCHAR(250)
);

-- Insert 120 prescriptions

INSERT INTO hospital.prescriptions
    (appointment_id, prescription_date, notes)
SELECT
    appointment_id,
    appointment_date::DATE,
    CASE
        WHEN appointment_id % 3 = 0 THEN 'Take medication as directed'
        WHEN appointment_id % 3 = 1 THEN 'Complete the prescribed course'
        ELSE 'Return for follow-up if necessary'
    END
FROM hospital.appointments
WHERE appointment_id <= 120;


-- 5. Create prescription items

CREATE TABLE hospital.prescription_items (
    prescription_item_id SERIAL PRIMARY KEY,
    prescription_id INTEGER NOT NULL
        REFERENCES hospital.prescriptions(prescription_id),
    medicine_id INTEGER NOT NULL
        REFERENCES hospital.medicines(medicine_id),
    dosage VARCHAR(100) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    duration_days INTEGER NOT NULL CHECK (duration_days > 0)
);

-- Insert 200 prescription items

INSERT INTO hospital.prescription_items
    (prescription_id, medicine_id, dosage, quantity, duration_days)
SELECT
    ((n - 1) % 120) + 1,
    ((n - 1) % 30) + 1,
    CASE
        WHEN n % 3 = 0 THEN 'Once daily'
        WHEN n % 3 = 1 THEN 'Twice daily'
        ELSE 'Three times daily'
    END,
    5 + (n % 26),
    3 + (n % 12)
FROM generate_series(1, 200) AS gs(n);


-- 6. Create payments

CREATE TABLE hospital.payments (
    payment_id SERIAL PRIMARY KEY,
    appointment_id INTEGER REFERENCES hospital.appointments(appointment_id),
    admission_id INTEGER REFERENCES hospital.admissions(admission_id),
    amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    payment_date DATE NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    CHECK (
        (appointment_id IS NOT NULL AND admission_id IS NULL)
        OR
        (appointment_id IS NULL AND admission_id IS NOT NULL)
    )
);

-- Insert 180 payments

INSERT INTO hospital.payments
    (appointment_id, admission_id, amount, payment_date,
     payment_method, payment_status)
SELECT
    n,
    NULL,
    500 + (n % 10) * 250,
    a.appointment_date::DATE,
    CASE
        WHEN n % 3 = 0 THEN 'M-Pesa'
        WHEN n % 3 = 1 THEN 'Cash'
        ELSE 'Card'
    END,
    CASE
        WHEN n % 10 = 0 THEN 'Pending'
        WHEN n % 10 = 1 THEN 'Failed'
        ELSE 'Paid'
    END
FROM generate_series(1, 150) AS gs(n)
JOIN hospital.appointments a ON a.appointment_id = n

UNION ALL

SELECT
    NULL,
    n,
    5000 + (n % 10) * 1500,
    a.admission_date,
    CASE
        WHEN n % 3 = 0 THEN 'M-Pesa'
        WHEN n % 3 = 1 THEN 'Cash'
        ELSE 'Card'
    END,
    CASE
        WHEN n % 10 = 0 THEN 'Pending'
        WHEN n % 10 = 1 THEN 'Failed'
        ELSE 'Paid'
    END
FROM generate_series(1, 30) AS gs(n)
JOIN hospital.admissions a ON a.admission_id = n;


COMMIT;


-- Verify all hospital tables and record counts

SELECT 'departments' AS table_name, COUNT(*) AS total_records
FROM hospital.departments

UNION ALL
SELECT 'doctors', COUNT(*) FROM hospital.doctors

UNION ALL
SELECT 'patients', COUNT(*) FROM hospital.patients

UNION ALL
SELECT 'appointments', COUNT(*) FROM hospital.appointments

UNION ALL
SELECT 'admissions', COUNT(*) FROM hospital.admissions

UNION ALL
SELECT 'medicines', COUNT(*) FROM hospital.medicines

UNION ALL
SELECT 'prescriptions', COUNT(*) FROM hospital.prescriptions

UNION ALL
SELECT 'prescription_items', COUNT(*) FROM hospital.prescription_items

UNION ALL
SELECT 'payments', COUNT(*) FROM hospital.payments;

-- Check existing hospital tables

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'hospital'
ORDER BY table_name;


-- Create and populate the remaining hospital tables

BEGIN;

-- Create appointments

CREATE TABLE hospital.appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES hospital.patients(patient_id),
    doctor_id INTEGER NOT NULL REFERENCES hospital.doctors(doctor_id),
    appointment_date TIMESTAMP NOT NULL,
    reason VARCHAR(200),
    status VARCHAR(20) NOT NULL
);

INSERT INTO hospital.appointments
    (patient_id, doctor_id, appointment_date, reason, status)
SELECT
    ((n - 1) % 100) + 1,
    ((n - 1) % 15) + 1,
    TIMESTAMP '2026-01-01 08:00:00'
        + ((n * 7) % 314) * INTERVAL '1 day'
        + (n % 9) * INTERVAL '1 hour',
    CASE
        WHEN n % 5 = 0 THEN 'Routine checkup'
        WHEN n % 5 = 1 THEN 'Follow-up consultation'
        WHEN n % 5 = 2 THEN 'Pain or discomfort'
        WHEN n % 5 = 3 THEN 'General examination'
        ELSE 'Specialist consultation'
    END,
    CASE
        WHEN n % 10 = 0 THEN 'Cancelled'
        WHEN n % 10 = 1 THEN 'No-show'
        WHEN n % 10 = 2 THEN 'Scheduled'
        ELSE 'Completed'
    END
FROM generate_series(1, 250) AS gs(n);


-- Create admissions

CREATE TABLE hospital.admissions (
    admission_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES hospital.patients(patient_id),
    doctor_id INTEGER NOT NULL REFERENCES hospital.doctors(doctor_id),
    appointment_id INTEGER UNIQUE REFERENCES hospital.appointments(appointment_id),
    admission_date DATE NOT NULL,
    discharge_date DATE,
    admission_reason VARCHAR(200),
    status VARCHAR(20) NOT NULL
);

INSERT INTO hospital.admissions
    (patient_id, doctor_id, appointment_id, admission_date,
     discharge_date, admission_reason, status)
SELECT
    a.patient_id,
    a.doctor_id,
    a.appointment_id,
    a.appointment_date::DATE,
    a.appointment_date::DATE + (2 + n % 9),
    CASE
        WHEN n % 4 = 0 THEN 'Observation and monitoring'
        WHEN n % 4 = 1 THEN 'Surgical procedure'
        WHEN n % 4 = 2 THEN 'Medical treatment'
        ELSE 'Emergency care'
    END,
    'Discharged'
FROM hospital.appointments a
JOIN generate_series(1, 40) AS gs(n)
    ON a.appointment_id = n;


-- Create medicines

CREATE TABLE hospital.medicines (
    medicine_id SERIAL PRIMARY KEY,
    medicine_name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

INSERT INTO hospital.medicines
    (medicine_name, category, unit_price, stock_quantity)
VALUES
    ('Paracetamol', 'Pain Relief', 50, 500),
    ('Ibuprofen', 'Pain Relief', 80, 300),
    ('Amoxicillin', 'Antibiotic', 150, 200),
    ('Azithromycin', 'Antibiotic', 250, 150),
    ('Cetirizine', 'Antihistamine', 60, 250),
    ('Loratadine', 'Antihistamine', 90, 200),
    ('Omeprazole', 'Gastrointestinal', 120, 180),
    ('Antacid Tablets', 'Gastrointestinal', 40, 300),
    ('Metformin', 'Diabetes', 100, 250),
    ('Insulin', 'Diabetes', 800, 80),
    ('Amlodipine', 'Cardiovascular', 110, 200),
    ('Losartan', 'Cardiovascular', 140, 180),
    ('Salbutamol Inhaler', 'Respiratory', 350, 100),
    ('Cough Syrup', 'Respiratory', 130, 160),
    ('Vitamin C', 'Vitamins', 70, 300),
    ('Vitamin D', 'Vitamins', 150, 180),
    ('Iron Tablets', 'Supplements', 90, 220),
    ('Calcium Tablets', 'Supplements', 120, 200),
    ('Hydrocortisone Cream', 'Dermatology', 180, 100),
    ('Antifungal Cream', 'Dermatology', 160, 120),
    ('Eye Drops', 'Eye Care', 100, 150),
    ('Ear Drops', 'Ear Care', 110, 100),
    ('ORS Sachets', 'Rehydration', 25, 500),
    ('Zinc Tablets', 'Supplements', 60, 250),
    ('Diclofenac', 'Pain Relief', 100, 180),
    ('Doxycycline', 'Antibiotic', 170, 140),
    ('Folic Acid', 'Vitamins', 50, 300),
    ('Multivitamins', 'Vitamins', 200, 160),
    ('Antiseptic Solution', 'First Aid', 90, 180),
    ('Loperamide', 'Gastrointestinal', 75, 200);


-- Create prescriptions

CREATE TABLE hospital.prescriptions (
    prescription_id SERIAL PRIMARY KEY,
    appointment_id INTEGER NOT NULL UNIQUE
        REFERENCES hospital.appointments(appointment_id),
    prescription_date DATE NOT NULL,
    notes VARCHAR(250)
);

INSERT INTO hospital.prescriptions
    (appointment_id, prescription_date, notes)
SELECT
    appointment_id,
    appointment_date::DATE,
    'Take medication as directed'
FROM hospital.appointments
WHERE appointment_id <= 120;


-- Create prescription items

CREATE TABLE hospital.prescription_items (
    prescription_item_id SERIAL PRIMARY KEY,
    prescription_id INTEGER NOT NULL
        REFERENCES hospital.prescriptions(prescription_id),
    medicine_id INTEGER NOT NULL
        REFERENCES hospital.medicines(medicine_id),
    dosage VARCHAR(100) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    duration_days INTEGER NOT NULL CHECK (duration_days > 0)
);

INSERT INTO hospital.prescription_items
    (prescription_id, medicine_id, dosage, quantity, duration_days)
SELECT
    ((n - 1) % 120) + 1,
    ((n - 1) % 30) + 1,
    CASE
        WHEN n % 3 = 0 THEN 'Once daily'
        WHEN n % 3 = 1 THEN 'Twice daily'
        ELSE 'Three times daily'
    END,
    5 + (n % 26),
    3 + (n % 12)
FROM generate_series(1, 200) AS gs(n);


-- Create payments

CREATE TABLE hospital.payments (
    payment_id SERIAL PRIMARY KEY,
    appointment_id INTEGER REFERENCES hospital.appointments(appointment_id),
    admission_id INTEGER REFERENCES hospital.admissions(admission_id),
    amount NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    payment_date DATE NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    CHECK (
        (appointment_id IS NOT NULL AND admission_id IS NULL)
        OR
        (appointment_id IS NULL AND admission_id IS NOT NULL)
    )
);

INSERT INTO hospital.payments
    (appointment_id, admission_id, amount, payment_date,
     payment_method, payment_status)
SELECT
    n, NULL, 500 + (n % 10) * 250,
    a.appointment_date::DATE,
    CASE WHEN n % 3 = 0 THEN 'M-Pesa'
         WHEN n % 3 = 1 THEN 'Cash'
         ELSE 'Card' END,
    CASE WHEN n % 10 = 0 THEN 'Pending'
         WHEN n % 10 = 1 THEN 'Failed'
         ELSE 'Paid' END
FROM generate_series(1, 150) AS gs(n)
JOIN hospital.appointments a ON a.appointment_id = n

UNION ALL

SELECT
    NULL, n, 5000 + (n % 10) * 1500,
    a.admission_date,
    CASE WHEN n % 3 = 0 THEN 'M-Pesa'
         WHEN n % 3 = 1 THEN 'Cash'
         ELSE 'Card' END,
    CASE WHEN n % 10 = 0 THEN 'Pending'
         WHEN n % 10 = 1 THEN 'Failed'
         ELSE 'Paid' END
FROM generate_series(1, 30) AS gs(n)
JOIN hospital.admissions a ON a.admission_id = n;

COMMIT;


--- Check appointments table

SELECT *
FROM hospital.appointments
LIMIT 5;

-- Create the appointments table

CREATE TABLE hospital.appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES hospital.patients(patient_id),
    doctor_id INTEGER NOT NULL REFERENCES hospital.doctors(doctor_id),
    appointment_date TIMESTAMP NOT NULL,
    reason VARCHAR(200),
    status VARCHAR(20) NOT NULL
);


-- Populate appointments and create the remaining hospital tables

BEGIN;

-- Insert 250 appointments

INSERT INTO hospital.appointments
    (patient_id, doctor_id, appointment_date, reason, status)
SELECT
    ((n - 1) % 100) + 1,
    ((n - 1) % 15) + 1,
    TIMESTAMP '2026-01-01 08:00:00'
        + ((n * 7) % 314) * INTERVAL '1 day'
        + (n % 9) * INTERVAL '1 hour',
    CASE
        WHEN n % 5 = 0 THEN 'Routine checkup'
        WHEN n % 5 = 1 THEN 'Follow-up consultation'
        WHEN n % 5 = 2 THEN 'Pain or discomfort'
        WHEN n % 5 = 3 THEN 'General examination'
        ELSE 'Specialist consultation'
    END,
    CASE
        WHEN n % 10 = 0 THEN 'Cancelled'
        WHEN n % 10 = 1 THEN 'No-show'
        WHEN n % 10 = 2 THEN 'Scheduled'
        ELSE 'Completed'
    END
FROM generate_series(1, 250) AS gs(n);


-- Create and populate admissions

CREATE TABLE hospital.admissions (
    admission_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES hospital.patients(patient_id),
    doctor_id INTEGER NOT NULL REFERENCES hospital.doctors(doctor_id),
    appointment_id INTEGER UNIQUE REFERENCES hospital.appointments(appointment_id),
    admission_date DATE NOT NULL,
    discharge_date DATE,
    admission_reason VARCHAR(200),
    status VARCHAR(20) NOT NULL
);

INSERT INTO hospital.admissions
    (patient_id, doctor_id, appointment_id, admission_date,
     discharge_date, admission_reason, status)
SELECT
    a.patient_id,
    a.doctor_id,
    a.appointment_id,
    a.appointment_date::DATE,
    a.appointment_date::DATE + (2 + n % 9),
    CASE
        WHEN n % 4 = 0 THEN 'Observation and monitoring'
        WHEN n % 4 = 1 THEN 'Surgical procedure'
        WHEN n % 4 = 2 THEN 'Medical treatment'
        ELSE 'Emergency care'
    END,
    'Discharged'
FROM hospital.appointments a
JOIN generate_series(1, 40) AS gs(n)
    ON a.appointment_id = n;


-- Create and populate medicines

CREATE TABLE hospital.medicines (
    medicine_id SERIAL PRIMARY KEY,
    medicine_name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

INSERT INTO hospital.medicines
    (medicine_name, category, unit_price, stock_quantity)
VALUES
    ('Paracetamol', 'Pain Relief', 50, 500),
    ('Ibuprofen', 'Pain Relief', 80, 300),
    ('Amoxicillin', 'Antibiotic', 150, 200),
    ('Azithromycin', 'Antibiotic', 250, 150),
    ('Cetirizine', 'Antihistamine', 60, 250),
    ('Loratadine', 'Antihistamine', 90, 200),
    ('Omeprazole', 'Gastrointestinal', 120, 180),
    ('Antacid Tablets', 'Gastrointestinal', 40, 300),
    ('Metformin', 'Diabetes', 100, 250),
    ('Insulin', 'Diabetes', 800, 80),
    ('Amlodipine', 'Cardiovascular', 110, 200),
    ('Losartan', 'Cardiovascular', 140, 180),
    ('Salbutamol Inhaler', 'Respiratory', 350, 100),
    ('Cough Syrup', 'Respiratory', 130, 160),
    ('Vitamin C', 'Vitamins', 70, 300),
    ('Vitamin D', 'Vitamins', 150, 180),
    ('Iron Tablets', 'Supplements', 90, 220),
    ('Calcium Tablets', 'Supplements', 120, 200),
    ('Hydrocortisone Cream', 'Dermatology', 180, 100),
    ('Antifungal Cream', 'Dermatology', 160, 120),
    ('Eye Drops', 'Eye Care', 100, 150),
    ('Ear Drops', 'Ear Care', 110, 100),
    ('ORS Sachets', 'Rehydration', 25, 500),
    ('Zinc Tablets', 'Supplements', 60, 250),
    ('Diclofenac', 'Pain Relief', 100, 180),
    ('Doxycycline', 'Antibiotic', 170, 140),
    ('Folic Acid', 'Vitamins', 50, 300),
    ('Multivitamins', 'Vitamins', 200, 160),
    ('Antiseptic Solution', 'First Aid', 90, 180),
    ('Loperamide', 'Gastrointestinal', 75, 200);


-- Create and populate prescriptions

CREATE TABLE hospital.prescriptions (
    prescription_id SERIAL PRIMARY KEY,
    appointment_id INTEGER NOT NULL UNIQUE
        REFERENCES hospital.appointments(appointment_id),
    prescription_date DATE NOT NULL,
    notes VARCHAR(250)
);

INSERT INTO hospital.prescriptions
    (appointment_id, prescription_date, notes)
SELECT
    appointment_id,
    appointment_date::DATE,
    'Take medication as directed'
FROM hospital.appointments
WHERE appointment_id <= 120;


-- Create and populate prescription items

CREATE TABLE hospital.prescription_items (
    prescription_item_id SERIAL PRIMARY KEY,
    prescription_id INTEGER NOT NULL
        REFERENCES hospital.prescriptions(prescription_id),
    medicine_id INTEGER NOT NULL
        REFERENCES hospital.medicines(medicine_id),
    dosage VARCHAR(100) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    duration_days INTEGER NOT NULL CHECK (duration_days > 0)
);

INSERT INTO hospital.prescription_items
    (prescription_id, medicine_id, dosage, quantity, duration_days)
SELECT
    ((n - 1) % 120) + 1,
    ((n - 1) % 30) + 1,
    CASE
        WHEN n % 3 = 0 THEN 'Once daily'
        WHEN n % 3 = 1 THEN 'Twice daily'
        ELSE 'Three times daily'
    END,
    5 + (n % 26),
    3 + (n % 12)
FROM generate_series(1, 200) AS gs(n);


-- Create and populate payments

CREATE TABLE hospital.payments (
    payment_id SERIAL PRIMARY KEY,
    appointment_id INTEGER REFERENCES hospital.appointments(appointment_id),
    admission_id INTEGER REFERENCES hospital.admissions(admission_id),
    amount NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    payment_date DATE NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    CHECK (
        (appointment_id IS NOT NULL AND admission_id IS NULL)
        OR
        (appointment_id IS NULL AND admission_id IS NOT NULL)
    )
);

INSERT INTO hospital.payments
    (appointment_id, admission_id, amount, payment_date,
     payment_method, payment_status)
SELECT
    n,
    NULL,
    500 + (n % 10) * 250,
    a.appointment_date::DATE,
    CASE
        WHEN n % 3 = 0 THEN 'M-Pesa'
        WHEN n % 3 = 1 THEN 'Cash'
        ELSE 'Card'
    END,
    CASE
        WHEN n % 10 = 0 THEN 'Pending'
        WHEN n % 10 = 1 THEN 'Failed'
        ELSE 'Paid'
    END
FROM generate_series(1, 150) AS gs(n)
JOIN hospital.appointments a ON a.appointment_id = n

UNION ALL

SELECT
    NULL,
    n,
    5000 + (n % 10) * 1500,
    a.admission_date,
    CASE
        WHEN n % 3 = 0 THEN 'M-Pesa'
        WHEN n % 3 = 1 THEN 'Cash'
        ELSE 'Card'
    END,
    CASE
        WHEN n % 10 = 0 THEN 'Pending'
        WHEN n % 10 = 1 THEN 'Failed'
        ELSE 'Paid'
    END
FROM generate_series(1, 30) AS gs(n)
JOIN hospital.admissions a ON a.admission_id = n;

COMMIT;


-- Verify all six tables

SELECT 'appointments' AS table_name, COUNT(*) AS total_records
FROM hospital.appointments
UNION ALL
SELECT 'admissions', COUNT(*) FROM hospital.admissions
UNION ALL
SELECT 'medicines', COUNT(*) FROM hospital.medicines
UNION ALL
SELECT 'prescriptions', COUNT(*) FROM hospital.prescriptions
UNION ALL
SELECT 'prescription_items', COUNT(*) FROM hospital.prescription_items
UNION ALL
SELECT 'payments', COUNT(*) FROM hospital.payments;


-- Create and populate all remaining hospital tables

BEGIN;

-- 1. Create appointments if missing

CREATE TABLE IF NOT EXISTS hospital.appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES hospital.patients(patient_id),
    doctor_id INTEGER NOT NULL REFERENCES hospital.doctors(doctor_id),
    appointment_date TIMESTAMP NOT NULL,
    reason VARCHAR(200),
    status VARCHAR(20) NOT NULL
);

-- Insert appointments if the table is empty

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM hospital.appointments) THEN
        INSERT INTO hospital.appointments
            (patient_id, doctor_id, appointment_date, reason, status)
        SELECT
            ((n - 1) % 100) + 1,
            ((n - 1) % 15) + 1,
            TIMESTAMP '2026-01-01 08:00:00'
                + ((n * 7) % 314) * INTERVAL '1 day'
                + (n % 9) * INTERVAL '1 hour',
            CASE
                WHEN n % 5 = 0 THEN 'Routine checkup'
                WHEN n % 5 = 1 THEN 'Follow-up consultation'
                WHEN n % 5 = 2 THEN 'Pain or discomfort'
                WHEN n % 5 = 3 THEN 'General examination'
                ELSE 'Specialist consultation'
            END,
            CASE
                WHEN n % 10 = 0 THEN 'Cancelled'
                WHEN n % 10 = 1 THEN 'No-show'
                WHEN n % 10 = 2 THEN 'Scheduled'
                ELSE 'Completed'
            END
        FROM generate_series(1, 250) AS gs(n);
    END IF;
END $$;


-- 2. Create admissions

CREATE TABLE IF NOT EXISTS hospital.admissions (
    admission_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES hospital.patients(patient_id),
    doctor_id INTEGER NOT NULL REFERENCES hospital.doctors(doctor_id),
    appointment_id INTEGER UNIQUE REFERENCES hospital.appointments(appointment_id),
    admission_date DATE NOT NULL,
    discharge_date DATE,
    admission_reason VARCHAR(200),
    status VARCHAR(20) NOT NULL
);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM hospital.admissions) THEN
        INSERT INTO hospital.admissions
            (patient_id, doctor_id, appointment_id, admission_date,
             discharge_date, admission_reason, status)
        SELECT
            a.patient_id,
            a.doctor_id,
            a.appointment_id,
            a.appointment_date::DATE,
            a.appointment_date::DATE + (2 + n % 9),
            CASE
                WHEN n % 4 = 0 THEN 'Observation and monitoring'
                WHEN n % 4 = 1 THEN 'Surgical procedure'
                WHEN n % 4 = 2 THEN 'Medical treatment'
                ELSE 'Emergency care'
            END,
            'Discharged'
        FROM hospital.appointments a
        JOIN generate_series(1, 40) AS gs(n)
            ON a.appointment_id = n;
    END IF;
END $$;


-- 3. Create medicines

CREATE TABLE IF NOT EXISTS hospital.medicines (
    medicine_id SERIAL PRIMARY KEY,
    medicine_name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM hospital.medicines) THEN
        INSERT INTO hospital.medicines
            (medicine_name, category, unit_price, stock_quantity)
        VALUES
            ('Paracetamol', 'Pain Relief', 50, 500),
            ('Ibuprofen', 'Pain Relief', 80, 300),
            ('Amoxicillin', 'Antibiotic', 150, 200),
            ('Azithromycin', 'Antibiotic', 250, 150),
            ('Cetirizine', 'Antihistamine', 60, 250),
            ('Loratadine', 'Antihistamine', 90, 200),
            ('Omeprazole', 'Gastrointestinal', 120, 180),
            ('Antacid Tablets', 'Gastrointestinal', 40, 300),
            ('Metformin', 'Diabetes', 100, 250),
            ('Insulin', 'Diabetes', 800, 80),
            ('Amlodipine', 'Cardiovascular', 110, 200),
            ('Losartan', 'Cardiovascular', 140, 180),
            ('Salbutamol Inhaler', 'Respiratory', 350, 100),
            ('Cough Syrup', 'Respiratory', 130, 160),
            ('Vitamin C', 'Vitamins', 70, 300),
            ('Vitamin D', 'Vitamins', 150, 180),
            ('Iron Tablets', 'Supplements', 90, 220),
            ('Calcium Tablets', 'Supplements', 120, 200),
            ('Hydrocortisone Cream', 'Dermatology', 180, 100),
            ('Antifungal Cream', 'Dermatology', 160, 120),
            ('Eye Drops', 'Eye Care', 100, 150),
            ('Ear Drops', 'Ear Care', 110, 100),
            ('ORS Sachets', 'Rehydration', 25, 500),
            ('Zinc Tablets', 'Supplements', 60, 250),
            ('Diclofenac', 'Pain Relief', 100, 180),
            ('Doxycycline', 'Antibiotic', 170, 140),
            ('Folic Acid', 'Vitamins', 50, 300),
            ('Multivitamins', 'Vitamins', 200, 160),
            ('Antiseptic Solution', 'First Aid', 90, 180),
            ('Loperamide', 'Gastrointestinal', 75, 200);
    END IF;
END $$;


-- 4. Create prescriptions

CREATE TABLE IF NOT EXISTS hospital.prescriptions (
    prescription_id SERIAL PRIMARY KEY,
    appointment_id INTEGER NOT NULL UNIQUE
        REFERENCES hospital.appointments(appointment_id),
    prescription_date DATE NOT NULL,
    notes VARCHAR(250)
);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM hospital.prescriptions) THEN
        INSERT INTO hospital.prescriptions
            (appointment_id, prescription_date, notes)
        SELECT
            appointment_id,
            appointment_date::DATE,
            'Take medication as directed'
        FROM hospital.appointments
        WHERE appointment_id <= 120;
    END IF;
END $$;


-- 5. Create prescription items

CREATE TABLE IF NOT EXISTS hospital.prescription_items (
    prescription_item_id SERIAL PRIMARY KEY,
    prescription_id INTEGER NOT NULL
        REFERENCES hospital.prescriptions(prescription_id),
    medicine_id INTEGER NOT NULL
        REFERENCES hospital.medicines(medicine_id),
    dosage VARCHAR(100) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    duration_days INTEGER NOT NULL CHECK (duration_days > 0)
);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM hospital.prescription_items) THEN
        INSERT INTO hospital.prescription_items
            (prescription_id, medicine_id, dosage, quantity, duration_days)
        SELECT
            ((n - 1) % 120) + 1,
            ((n - 1) % 30) + 1,
            CASE
                WHEN n % 3 = 0 THEN 'Once daily'
                WHEN n % 3 = 1 THEN 'Twice daily'
                ELSE 'Three times daily'
            END,
            5 + (n % 26),
            3 + (n % 12)
        FROM generate_series(1, 200) AS gs(n);
    END IF;
END $$;


-- 6. Create payments

CREATE TABLE IF NOT EXISTS hospital.payments (
    payment_id SERIAL PRIMARY KEY,
    appointment_id INTEGER REFERENCES hospital.appointments(appointment_id),
    admission_id INTEGER REFERENCES hospital.admissions(admission_id),
    amount NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    payment_date DATE NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    CHECK (
        (appointment_id IS NOT NULL AND admission_id IS NULL)
        OR
        (appointment_id IS NULL AND admission_id IS NOT NULL)
    )
);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM hospital.payments) THEN
        INSERT INTO hospital.payments
            (appointment_id, admission_id, amount, payment_date,
             payment_method, payment_status)
        SELECT
            n,
            NULL,
            500 + (n % 10) * 250,
            a.appointment_date::DATE,
            CASE
                WHEN n % 3 = 0 THEN 'M-Pesa'
                WHEN n % 3 = 1 THEN 'Cash'
                ELSE 'Card'
            END,
            CASE
                WHEN n % 10 = 0 THEN 'Pending'
                WHEN n % 10 = 1 THEN 'Failed'
                ELSE 'Paid'
            END
        FROM generate_series(1, 150) AS gs(n)
        JOIN hospital.appointments a ON a.appointment_id = n

        UNION ALL

        SELECT
            NULL,
            n,
            5000 + (n % 10) * 1500,
            a.admission_date,
            CASE
                WHEN n % 3 = 0 THEN 'M-Pesa'
                WHEN n % 3 = 1 THEN 'Cash'
                ELSE 'Card'
            END,
            CASE
                WHEN n % 10 = 0 THEN 'Pending'
                WHEN n % 10 = 1 THEN 'Failed'
                ELSE 'Paid'
            END
        FROM generate_series(1, 30) AS gs(n)
        JOIN hospital.admissions a ON a.admission_id = n;
    END IF;
END $$;

COMMIT;


-- Verify all six remaining tables

SELECT 'appointments' AS table_name, COUNT(*) AS total_records
FROM hospital.appointments
UNION ALL
SELECT 'admissions', COUNT(*) FROM hospital.admissions
UNION ALL
SELECT 'medicines', COUNT(*) FROM hospital.medicines
UNION ALL
SELECT 'prescriptions', COUNT(*) FROM hospital.prescriptions
UNION ALL
SELECT 'prescription_items', COUNT(*) FROM hospital.prescription_items
UNION ALL
SELECT 'payments', COUNT(*) FROM hospital.payments;

-- Create all remaining hospital tables and insert their records


BEGIN;
-- Create the appointments table
CREATE TABLE IF NOT EXISTS hospital.appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES hospital.patients(patient_id),
    doctor_id INTEGER NOT NULL REFERENCES hospital.doctors(doctor_id),
    appointment_date TIMESTAMP NOT NULL,
    reason VARCHAR(200),
    status VARCHAR(20) NOT NULL
);

-- Create the admissions table
CREATE TABLE IF NOT EXISTS hospital.admissions (
    admission_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES hospital.patients(patient_id),
    doctor_id INTEGER NOT NULL REFERENCES hospital.doctors(doctor_id),
    appointment_id INTEGER REFERENCES hospital.appointments(appointment_id),
    admission_date DATE NOT NULL,
    discharge_date DATE,
    room_number VARCHAR(20),
    diagnosis VARCHAR(200),
    status VARCHAR(20) NOT NULL
);

-- Create the medicines table
CREATE TABLE IF NOT EXISTS hospital.medicines (
    medicine_id SERIAL PRIMARY KEY,
    medicine_name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(100),
    unit_price NUMERIC(10,2) NOT NULL,
    stock_quantity INTEGER NOT NULL
);

-- Create the prescriptions table
CREATE TABLE IF NOT EXISTS hospital.prescriptions (
    prescription_id SERIAL PRIMARY KEY,
    appointment_id INTEGER NOT NULL REFERENCES hospital.appointments(appointment_id),
    prescribed_date DATE NOT NULL,
    notes VARCHAR(200)
);

-- Create the prescription items table
CREATE TABLE IF NOT EXISTS hospital.prescription_items (
    item_id SERIAL PRIMARY KEY,
    prescription_id INTEGER NOT NULL REFERENCES hospital.prescriptions(prescription_id),
    medicine_id INTEGER NOT NULL REFERENCES hospital.medicines(medicine_id),
    dosage VARCHAR(50),
    frequency VARCHAR(100),
    duration_days INTEGER,
    quantity INTEGER NOT NULL
);

-- Create the payments table
CREATE TABLE IF NOT EXISTS hospital.payments (
    payment_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES hospital.patients(patient_id),
    appointment_id INTEGER REFERENCES hospital.appointments(appointment_id),
    admission_id INTEGER REFERENCES hospital.admissions(admission_id),
    amount NUMERIC(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(30),
    payment_status VARCHAR(20) NOT NULL,
    CONSTRAINT payment_reference_check
        CHECK (
            (appointment_id IS NOT NULL AND admission_id IS NULL)
            OR
            (appointment_id IS NULL AND admission_id IS NOT NULL)
        )
);

-- Insert 250 appointments
INSERT INTO hospital.appointments
    (appointment_id, patient_id, doctor_id, appointment_date, reason, status)
SELECT
    n,
    ((n - 1) % 100) + 1,
    ((n - 1) % 15) + 1,
    TIMESTAMP '2026-01-01 09:00:00'
        + ((n * 7) % 314) * INTERVAL '1 day'
        + (n % 8) * INTERVAL '1 hour',
    CASE n % 5
        WHEN 0 THEN 'Routine checkup'
        WHEN 1 THEN 'Follow-up consultation'
        WHEN 2 THEN 'General examination'
        WHEN 3 THEN 'Pain or discomfort'
        ELSE 'Specialist consultation'
    END,
    CASE n % 4
        WHEN 0 THEN 'Completed'
        WHEN 1 THEN 'Completed'
        WHEN 2 THEN 'Scheduled'
        ELSE 'Cancelled'
    END
FROM generate_series(1, 250) AS n
ON CONFLICT (appointment_id) DO NOTHING;

-- Insert 40 admissions
INSERT INTO hospital.admissions
    (admission_id, patient_id, doctor_id, appointment_id,
     admission_date, discharge_date, room_number, diagnosis, status)
SELECT
    n,
    ((n - 1) % 100) + 1,
    ((n - 1) % 15) + 1,
    n,
    DATE '2026-02-01' + (n * 5),
    CASE
        WHEN n % 4 = 0 THEN NULL
        ELSE DATE '2026-02-01' + (n * 5) + (n % 10) + 1
    END,
    'ROOM-' || LPAD(n::TEXT, 3, '0'),
    CASE n % 5
        WHEN 0 THEN 'Pneumonia'
        WHEN 1 THEN 'Malaria'
        WHEN 2 THEN 'Appendicitis'
        WHEN 3 THEN 'Severe infection'
        ELSE 'Observation and treatment'
    END,
    CASE
        WHEN n % 4 = 0 THEN 'Admitted'
        ELSE 'Discharged'
    END
FROM generate_series(1, 40) AS n
ON CONFLICT (admission_id) DO NOTHING;

-- Insert 30 medicines
INSERT INTO hospital.medicines
    (medicine_id, medicine_name, category, unit_price, stock_quantity)
VALUES
    (1, 'Paracetamol', 'Pain Relief', 50.00, 500),
    (2, 'Ibuprofen', 'Pain Relief', 80.00, 350),
    (3, 'Amoxicillin', 'Antibiotic', 150.00, 200),
    (4, 'Azithromycin', 'Antibiotic', 250.00, 180),
    (5, 'Cetirizine', 'Antihistamine', 60.00, 300),
    (6, 'Loratadine', 'Antihistamine', 90.00, 250),
    (7, 'Omeprazole', 'Gastric', 120.00, 220),
    (8, 'Metformin', 'Diabetes', 100.00, 280),
    (9, 'Insulin', 'Diabetes', 650.00, 100),
    (10, 'Amlodipine', 'Blood Pressure', 110.00, 240),
    (11, 'Losartan', 'Blood Pressure', 180.00, 190),
    (12, 'Salbutamol', 'Respiratory', 130.00, 160),
    (13, 'Cough Syrup', 'Respiratory', 150.00, 200),
    (14, 'ORS', 'Rehydration', 30.00, 400),
    (15, 'Vitamin C', 'Vitamins', 70.00, 300),
    (16, 'Vitamin D', 'Vitamins', 140.00, 180),
    (17, 'Calcium Tablets', 'Supplements', 160.00, 150),
    (18, 'Iron Tablets', 'Supplements', 90.00, 220),
    (19, 'Ciprofloxacin', 'Antibiotic', 170.00, 190),
    (20, 'Doxycycline', 'Antibiotic', 140.00, 160),
    (21, 'Diclofenac', 'Pain Relief', 100.00, 210),
    (22, 'Aspirin', 'Pain Relief', 45.00, 350),
    (23, 'Ranitidine', 'Gastric', 80.00, 200),
    (24, 'Multivitamins', 'Vitamins', 200.00, 180),
    (25, 'Hydrocortisone Cream', 'Skin Care', 120.00, 140),
    (26, 'Clotrimazole Cream', 'Skin Care', 100.00, 160),
    (27, 'Eye Drops', 'Eye Care', 90.00, 130),
    (28, 'Antiseptic Solution', 'First Aid', 180.00, 100),
    (29, 'Folic Acid', 'Supplements', 50.00, 250),
    (30, 'Zinc Tablets', 'Supplements', 75.00, 220)
ON CONFLICT (medicine_id) DO NOTHING;

-- Insert 120 prescriptions
INSERT INTO hospital.prescriptions
    (prescription_id, appointment_id, prescribed_date, notes)
SELECT
    n,
    n,
    DATE '2026-01-01' + (n * 7),
    CASE n % 3
        WHEN 0 THEN 'Take medication as directed'
        WHEN 1 THEN 'Complete the prescribed course'
        ELSE 'Return for follow-up if necessary'
    END
FROM generate_series(1, 120) AS n
ON CONFLICT (prescription_id) DO NOTHING;

-- Insert 200 prescription items
INSERT INTO hospital.prescription_items
    (item_id, prescription_id, medicine_id, dosage,
     frequency, duration_days, quantity)
SELECT
    n,
    ((n - 1) % 120) + 1,
    ((n - 1) % 30) + 1,
    CASE n % 3
        WHEN 0 THEN '500 mg'
        WHEN 1 THEN '250 mg'
        ELSE '100 mg'
    END,
    CASE n % 3
        WHEN 0 THEN 'Twice daily'
        WHEN 1 THEN 'Once daily'
        ELSE 'Three times daily'
    END,
    (n % 10) + 3,
    (n % 20) + 10
FROM generate_series(1, 200) AS n
ON CONFLICT (item_id) DO NOTHING;

-- Insert 180 payments
INSERT INTO hospital.payments
    (payment_id, patient_id, appointment_id, admission_id,
     amount, payment_date, payment_method, payment_status)
SELECT
    n,
    CASE
        WHEN n <= 150 THEN ((n - 1) % 100) + 1
        ELSE ((n - 151) % 100) + 1
    END,
    CASE WHEN n <= 150 THEN n ELSE NULL END,
    CASE WHEN n > 150 THEN n - 150 ELSE NULL END,
    500 + (n * 175 % 15000),
    DATE '2026-03-01' + (n * 3),
    CASE n % 3
        WHEN 0 THEN 'M-Pesa'
        WHEN 1 THEN 'Cash'
        ELSE 'Card'
    END,
    CASE n % 4
        WHEN 0 THEN 'Pending'
        ELSE 'Paid'
    END
FROM generate_series(1, 180) AS n
ON CONFLICT (payment_id) DO NOTHING;

-- Synchronize ID sequences for future inserts
SELECT setval(pg_get_serial_sequence('hospital.appointments', 'appointment_id'),
              (SELECT MAX(appointment_id) FROM hospital.appointments));
SELECT setval(pg_get_serial_sequence('hospital.admissions', 'admission_id'),
              (SELECT MAX(admission_id) FROM hospital.admissions));
SELECT setval(pg_get_serial_sequence('hospital.medicines', 'medicine_id'),
              (SELECT MAX(medicine_id) FROM hospital.medicines));
SELECT setval(pg_get_serial_sequence('hospital.prescriptions', 'prescription_id'),
              (SELECT MAX(prescription_id) FROM hospital.prescriptions));
SELECT setval(pg_get_serial_sequence('hospital.prescription_items', 'item_id'),
              (SELECT MAX(item_id) FROM hospital.prescription_items));
SELECT setval(pg_get_serial_sequence('hospital.payments', 'payment_id'),
              (SELECT MAX(payment_id) FROM hospital.payments));

COMMIT;

-- Verify the record counts in all nine tables
SELECT 'departments' AS table_name, COUNT(*) AS total_records FROM hospital.departments
UNION ALL
SELECT 'doctors', COUNT(*) FROM hospital.doctors
UNION ALL
SELECT 'patients', COUNT(*) FROM hospital.patients
UNION ALL
SELECT 'appointments', COUNT(*) FROM hospital.appointments
UNION ALL
SELECT 'admissions', COUNT(*) FROM hospital.admissions
UNION ALL
SELECT 'medicines', COUNT(*) FROM hospital.medicines
UNION ALL
SELECT 'prescriptions', COUNT(*) FROM hospital.prescriptions
UNION ALL
SELECT 'prescription_items', COUNT(*) FROM hospital.prescription_items
UNION ALL
SELECT 'payments', COUNT(*) FROM hospital.payments;

