# Feature Engineering of a bank's customers with MySQL

This project builds a **single, denormalized dataset** of a bank's customers from a relational banking database using **MySQL**. The goal is to obtain behavioral and financial activity indicators (features) from multiple tables including data on customers, their accounts, and their transactions. The resulting output can be used for advanced data analytics and machine learning tasks.

---

## Database

The project uses a MySQL database (**`bank`**), contained in the banking_db.sql file, which is composed of five tables:

- **`customer`**: customer personal information  
  - Columns: `customer_id`, `customer_name`, `customer_surname`, `customer_birth_date`
- **`account`**: accounts owned by customers  
  - Columns: `account_id`, `customer_id`, `account_type_id`
- **`account_type`**: reference table of account types
  - Columns: `account_type_id`, `account_type_desc` (e.g., *Basic*, *Business*, *Private*, *Family*)
- **`transaction_type`**: reference table of transaction types
  - Columns: `transaction_type_id`, `transaction_type_desc`, `transaction_sign`
- **`transactions`**: transactions made by individual accounts
  - Columns: `transaction_date`, `transaction_type_id`, `amount`, `account_id`

For this project transactions are classified as **outgoing** when `amount < 0` and **incoming** when `amount > 0`. The result of the project is a **denormalized table with 27 features** and **200 rows** (one per customer), which is not stored as a physical or temporary table, but is produced as the result of a single `SELECT` query.

---

## Objectives and Methods
