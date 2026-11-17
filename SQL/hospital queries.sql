-- Hospital executive KPI summary
SELECT
    (SELECT COUNT(*) FROM hospital.patients) AS total_patients,
    (SELECT COUNT(*) FROM hospital.doctors) AS total_doctors,
    (SELECT COUNT(*) FROM hospital.departments) AS total_departments,
    (SELECT COUNT(*) FROM hospital.appointments
     WHERE appointment_date::DATE <= CURRENT_DATE) AS appointments_to_date,
    (SELECT COUNT(*) FROM hospital.admissions
     WHERE admission_date <= CURRENT_DATE) AS admissions_to_date,
    (SELECT COALESCE(SUM(amount), 0)
     FROM hospital.payments
     WHERE payment_status = 'Paid'
       AND payment_date <= CURRENT_DATE) AS paid_revenue,
    (SELECT COUNT(*) FROM hospital.payments
     WHERE payment_status = 'Pending'
       AND payment_date <= CURRENT_DATE) AS pending_payments;

-- Patient demographics by gender
SELECT
    gender,
    COUNT(*) AS total_patients
FROM hospital.patients
GROUP BY gender
ORDER BY total_patients DESC;

-- Monthly patient registration trend
SELECT
    DATE_TRUNC('month', registration_date)::DATE AS registration_month,
    COUNT(*) AS new_patients
FROM hospital.patients
WHERE registration_date <= CURRENT_DATE
GROUP BY registration_month
ORDER BY registration_month;

-- Appointment distribution by status
SELECT
    status,
    COUNT(*) AS total_appointments
FROM hospital.appointments
WHERE appointment_date::DATE <= CURRENT_DATE
GROUP BY status
ORDER BY total_appointments DESC;

-- Monthly appointment trend
SELECT
    DATE_TRUNC('month', appointment_date)::DATE AS appointment_month,
    COUNT(*) AS total_appointments
FROM hospital.appointments
WHERE appointment_date::DATE <= CURRENT_DATE
GROUP BY appointment_month
ORDER BY appointment_month;

-- Appointment workload by department
SELECT
    d.department_name,
    COUNT(a.appointment_id) AS total_appointments
FROM hospital.appointments a
JOIN hospital.doctors doc
    ON a.doctor_id = doc.doctor_id
JOIN hospital.departments d
    ON doc.department_id = d.department_id
WHERE a.appointment_date::DATE <= CURRENT_DATE
GROUP BY d.department_name
ORDER BY total_appointments DESC;

-- Doctor workload and appointment counts
SELECT
    doc.doctor_id,
    doc.doctor_name,
    doc.specialization,
    d.department_name,
    COUNT(a.appointment_id) AS total_appointments
FROM hospital.doctors doc
JOIN hospital.departments d
    ON doc.department_id = d.department_id
LEFT JOIN hospital.appointments a
    ON doc.doctor_id = a.doctor_id
    AND a.appointment_date::DATE <= CURRENT_DATE
GROUP BY
    doc.doctor_id,
    doc.doctor_name,
    doc.specialization,
    d.department_name
ORDER BY total_appointments DESC;

-- Hospital admissions by status
SELECT
    status,
    COUNT(*) AS total_admissions
FROM hospital.admissions
WHERE admission_date <= CURRENT_DATE
GROUP BY status
ORDER BY total_admissions DESC;

-- Admissions by department
SELECT
    d.department_name,
    COUNT(ad.admission_id) AS total_admissions
FROM hospital.admissions ad
JOIN hospital.doctors doc
    ON ad.doctor_id = doc.doctor_id
JOIN hospital.departments d
    ON doc.department_id = d.department_id
WHERE ad.admission_date <= CURRENT_DATE
GROUP BY d.department_name
ORDER BY total_admissions DESC;

-- Average length of hospital stay
SELECT
    ROUND(
        AVG(COALESCE(discharge_date, CURRENT_DATE) - admission_date),
        1
    ) AS average_stay_days,
    MAX(COALESCE(discharge_date, CURRENT_DATE) - admission_date)
        AS longest_stay_days,
    COUNT(*) AS total_admissions
FROM hospital.admissions
WHERE admission_date <= CURRENT_DATE;

-- Monthly paid revenue
SELECT
    DATE_TRUNC('month', payment_date)::DATE AS payment_month,
    COUNT(*) AS paid_transactions,
    SUM(amount) AS total_revenue
FROM hospital.payments
WHERE payment_status = 'Paid'
  AND payment_date <= CURRENT_DATE
GROUP BY payment_month
ORDER BY payment_month;

-- Paid revenue by payment method
SELECT
    payment_method,
    COUNT(*) AS total_transactions,
    SUM(amount) AS total_revenue
FROM hospital.payments
WHERE payment_status = 'Paid'
  AND payment_date <= CURRENT_DATE
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- Paid revenue by service type
SELECT
    CASE
        WHEN appointment_id IS NOT NULL THEN 'Appointments'
        WHEN admission_id IS NOT NULL THEN 'Admissions'
    END AS service_type,
    COUNT(*) AS total_transactions,
    SUM(amount) AS total_revenue
FROM hospital.payments
WHERE payment_status = 'Paid'
  AND payment_date <= CURRENT_DATE
GROUP BY service_type
ORDER BY total_revenue DESC;

-- Medicine inventory and prescription demand
SELECT
    m.medicine_id,
    m.medicine_name,
    m.category,
    m.unit_price,
    m.stock_quantity,
    m.unit_price * m.stock_quantity AS inventory_value,
    COUNT(pi.item_id) AS prescription_count,
    COALESCE(SUM(pi.quantity), 0) AS total_quantity_prescribed
FROM hospital.medicines m
LEFT JOIN hospital.prescription_items pi
    ON m.medicine_id = pi.medicine_id
GROUP BY
    m.medicine_id,
    m.medicine_name,
    m.category,
    m.unit_price,
    m.stock_quantity
ORDER BY total_quantity_prescribed DESC;

-- Identify patients with the most appointments
SELECT
    p.patient_id,
    p.patient_name,
    COUNT(a.appointment_id) AS total_appointments
FROM hospital.patients p
LEFT JOIN hospital.appointments a
    ON p.patient_id = a.patient_id
    AND a.appointment_date::DATE <= CURRENT_DATE
GROUP BY p.patient_id, p.patient_name
ORDER BY total_appointments DESC
LIMIT 20;

-- Detailed patient payment transactions
SELECT
    p.payment_id,
    pat.patient_id,
    pat.patient_name,
    p.appointment_id,
    p.admission_id,
    p.amount,
    p.payment_date,
    p.payment_method,
    p.payment_status,
    CASE
        WHEN p.appointment_id IS NOT NULL THEN 'Appointment'
        WHEN p.admission_id IS NOT NULL THEN 'Admission'
    END AS service_type
FROM hospital.payments p
JOIN hospital.patients pat
    ON p.patient_id = pat.patient_id
ORDER BY p.payment_date, p.payment_id;

-- Detailed prescription records
SELECT
    pr.prescription_id,
    pr.prescribed_date,
    p.patient_id,
    p.patient_name,
    m.medicine_name,
    m.category,
    pi.dosage,
    pi.frequency,
    pi.duration_days,
    pi.quantity
FROM hospital.prescriptions pr
JOIN hospital.appointments a
    ON pr.appointment_id = a.appointment_id
JOIN hospital.patients p
    ON a.patient_id = p.patient_id
JOIN hospital.prescription_items pi
    ON pr.prescription_id = pi.prescription_id
JOIN hospital.medicines m
    ON pi.medicine_id = m.medicine_id
ORDER BY pr.prescribed_date DESC;