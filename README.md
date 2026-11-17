 # Hospital Database Analysis

## Project Overview

This project focuses on designing and analysing a Hospital Management Database using **PostgreSQL and SQL**. The goal is to organise hospital data, perform meaningful analysis, and generate insights that can support better understanding of hospital operations, patient activity, financial performance, and medicine inventory.

The database contains nine related tables with 941 fictional records. SQL queries are used to extract, transform, aggregate, and analyse the data in preparation for interactive visualisation using Microsoft Power BI.

## Tools & Technologies

- **PostgreSQL** – Database creation, storage, and management.
- **DBeaver** – SQL development and database management.
- **SQL** – Data querying, filtering, aggregation, and relational analysis.
- **Microsoft Power BI** – Planned data visualisation and dashboard development.

## Database Structure

The database consists of nine tables:

| Table | Records | Description |
|---|---:|---|
| departments | 6 | Hospital departments |
| doctors | 15 | Doctor information and specialisations |
| patients | 100 | Patient demographics and registration details |
| appointments | 250 | Patient appointments and their status |
| admissions | 40 | Hospital admission records |
| medicines | 30 | Medicine inventory and pricing |
| prescriptions | 120 | Prescription records |
| prescription_items | 200 | Medicines and quantities prescribed |
| payments | 180 | Patient payment transactions |
| **Total** | **941** | |

## SQL Analysis

The project includes SQL queries covering the following areas:

### 1. Hospital Overview
- Total patients, doctors, and departments.
- Total appointments and admissions.
- Paid revenue and pending payments.

### 2. Patient Analytics
- Patient distribution by gender.
- Patient age-group analysis.
- Monthly patient registration trends.
- Patients with the highest number of appointments.

### 3. Appointment & Clinical Analytics
- Appointments by status.
- Monthly appointment trends.
- Appointment distribution by department.
- Doctor workload and appointment counts.
- Admissions by status and department.
- Average hospital stay.

### 4. Financial Analysis
- Monthly hospital revenue.
- Revenue by payment method.
- Revenue by service type.
- Detailed patient payment transactions.

### 5. Pharmacy & Inventory Analysis
- Medicine inventory and stock levels.
- Inventory valuation.
- Medicine prescription demand.
- Prescription details and quantities.

## Key SQL Concepts Applied

Throughout this project, I applied:

- SELECT, WHERE, ORDER BY
- GROUP BY and aggregate functions
- INNER JOIN and LEFT JOIN
- Subqueries
- CASE statements
- Common date and time functions
- COUNT, SUM, AVG, MIN, and MAX
- Data filtering and sorting
- Relational database management
- Primary keys and foreign key relationships

## Power BI Dashboard Development

The SQL analysis is being prepared for Power BI visualisation, with four planned dashboard sections:

1. **Executive Overview** – Hospital KPIs, appointments, admissions, and revenue.
2. **Patient & Clinical Analytics** – Patient demographics, doctor workload, and department activity.
3. **Financial Performance** – Revenue trends, payment methods, and transaction analysis.
4. **Pharmacy & Inventory** – Medicine stock, inventory value, and prescription demand.

## Project Structure

```text
Hospital-Database-Analysis/
│
├── SQL/
│   ├── hospital_database_setup.sql
│   └── hospital_queries.sql
│
├── Data/
│   └── CSV exports
│
├── PowerBI/
│   └── Dashboard files (.pbix)
│
└── README.md
```

*The folder structure represents the intended organisation of the project. Add the corresponding files as they are saved to the repository.*

## Key Learning Outcomes

- Designed a relational hospital database with multiple interconnected tables.
- Practised managing data using PostgreSQL.
- Developed SQL queries to analyse hospital operations.
- Used joins to combine information across related tables.
- Generated analytical datasets for business intelligence.
- Prepared SQL outputs for Power BI dashboard development.

## Data Disclaimer

This project uses fictional, synthetically generated data for educational and portfolio purposes. It does not contain actual patient records or represent the performance of a real hospital.

## Author

**Abdikadir Mohamed (Dadir)**

Aspiring Data Analyst | SQL | PostgreSQL | Power BI | Excel

GitHub: [Dadir43](https://github.com/Dadir43)

---

*This project demonstrates practical SQL database development and analytical skills as part of my data analytics learning journey.*
